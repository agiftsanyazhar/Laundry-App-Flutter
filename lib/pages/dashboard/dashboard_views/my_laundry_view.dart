import 'package:d_info/d_info.dart';
import 'package:d_input/d_input.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:laundry_app_flutter/config/app_constants.dart';
import 'package:laundry_app_flutter/config/app_format.dart';
import 'package:laundry_app_flutter/config/app_session.dart';
import 'package:laundry_app_flutter/config/failure.dart';
import 'package:laundry_app_flutter/config/nav.dart';
import 'package:laundry_app_flutter/datasources/laundry_datasource.dart';
import 'package:laundry_app_flutter/models/laundry_model.dart';
import 'package:laundry_app_flutter/models/user_model.dart';
import 'package:laundry_app_flutter/pages/dashboard/detail_laundry_page.dart';
import 'package:laundry_app_flutter/providers/my_laundry_provider.dart';
import 'package:laundry_app_flutter/widgets/error_background.dart';

class MyLaundryview extends ConsumerStatefulWidget {
  const MyLaundryview({super.key});

  @override
  ConsumerState<MyLaundryview> createState() => _MyLaundryviewState();
}

class _MyLaundryviewState extends ConsumerState<MyLaundryview> {
  late UserModel user;

  getMylaundry() {
    LaundryDatasource.readByUser(user.id).then((value) {
      value.fold(
        (failure) {
          switch (failure.runtimeType) {
            case BadRequestFailure:
              setMyLaundryStatus(ref, 'Bad request');
              break;
            case UnauthorizedFailure:
              setMyLaundryStatus(ref, "Unauthorized");
              break;
            case ForbiddenFailure:
              setMyLaundryStatus(ref, "You don't have permission");
              break;
            case NotFoundFailure:
              setMyLaundryStatus(ref, "Error not found");
              break;
            case InvalidInputFailure:
              setMyLaundryStatus(ref, "Invalid input");
              break;
            case ServerFailure:
              setMyLaundryStatus(ref, "Server error");
              break;
            default:
              setMyLaundryStatus(ref, "Request error");
              break;
          }
        },
        (result) {
          setMyLaundryStatus(ref, "Success");
          List data = result['data'];
          List<LaundryModel> laundries =
              data.map((e) => LaundryModel.fromJson(e)).toList();
          ref.read(myLaundryListProvider.notifier).setData(laundries);
        },
      );
    });
  }

  dialogClaim() {
    final editLaundryId = TextEditingController();
    final editClaimCode = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Form(
          key: formKey,
          child: SimpleDialog(
            titlePadding: const EdgeInsets.all(16),
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: const Text('Claim'),
            children: [
              DInput(
                controller: editLaundryId,
                title: 'Laundry ID',
                radius: BorderRadius.circular(10),
                validator: (input) => input == '' ? 'Required' : null,
                inputType: TextInputType.number,
              ),
              DView.height(),
              DInput(
                controller: editClaimCode,
                title: 'Claim Code',
                radius: BorderRadius.circular(10),
                validator: (input) => input == '' ? 'Required' : null,
              ),
              DView.height(20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    claimCode(editLaundryId.text, editClaimCode.text);
                  }
                },
                child: const Text('Claim Now'),
              ),
              DView.height(20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  claimCode(String id, String claimCode) {
    LaundryDatasource.claim(id, claimCode).then((value) {
      value.fold(
        (failure) {
          switch (failure.runtimeType) {
            case BadRequestFailure:
              DInfo.toastError('Bad request');
              break;
            case UnauthorizedFailure:
              DInfo.toastError("Unauthorized");
              break;
            case ForbiddenFailure:
              DInfo.toastError("You don't have permission");
              break;
            case NotFoundFailure:
              DInfo.toastError("Error not found");
              break;
            case InvalidInputFailure:
              DInfo.toastError("Invalid input");
              break;
            case ServerFailure:
              DInfo.toastError("Server error");
              break;
            default:
              DInfo.toastError("Request error");
              break;
          }
        },
        (result) {
          DInfo.toastError("Claim success");
          getMylaundry();
        },
      );
    });
  }

  @override
  void initState() {
    AppSession.getUser().then((value) {
      user = value!;

      getMylaundry();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header(),
        category(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => getMylaundry(),
            child: Consumer(
              builder: (_, wiRef, __) {
                String statusList = wiRef.watch(myLaundryStatusProvider);
                String statusCategory = wiRef.watch(myLaundryCategoryProvider);
                List<LaundryModel> listBackup =
                    wiRef.watch(myLaundryListProvider);

                if (statusList == '') {
                  return DView.loadingCircle();
                }

                if (statusList != 'Success') {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 80),
                    child: ErrorBackground(
                      ratio: 16 / 9,
                      message: statusList,
                    ),
                  );
                }

                List<LaundryModel> list = [];

                if (statusCategory == 'All') {
                  list = List.from(listBackup);
                } else {
                  list = listBackup
                      .where((element) => element.status == statusCategory)
                      .toList();
                }

                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(30, 30, 30, 80),
                    child: Stack(
                      children: [
                        const ErrorBackground(
                          ratio: 16 / 9,
                          message: 'Empty',
                        ),
                        IconButton(
                          onPressed: () => getMylaundry(),
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GroupedListView<LaundryModel, String>(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 80),
                  elements: list,
                  groupBy: (element) => AppFormat.shortDate(element.createdAt),
                  order: GroupedListOrder.DESC,
                  itemComparator: (element1, element2) {
                    return element1.createdAt.compareTo(element2.updatedAt);
                  },
                  groupSeparatorBuilder: (value) => Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      margin: const EdgeInsets.only(
                        top: 24,
                        bottom: 20,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        AppFormat.fullDate(value),
                      ),
                    ),
                  ),
                  itemBuilder: (context, laundry) {
                    return GestureDetector(
                      onTap: () {
                        Nav.push(context, DetailLaundryPage(laundry: laundry));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    laundry.shop.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                DView.width(),
                                Text(
                                  AppFormat.longPrice(laundry.total),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            DView.height(12),
                            Row(
                              children: [
                                if (laundry.withDelivery)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    child: const Text(
                                      'Delivery',
                                      style: TextStyle(
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                if (laundry.withPickup)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    child: const Text(
                                      'Delivery',
                                      style: TextStyle(
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    '${laundry.weight} kg',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Padding header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Laundry',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: OutlinedButton.icon(
              onPressed: () => dialogClaim(),
              icon: const Icon(Icons.add),
              label: const Text(
                'Claim',
                style: TextStyle(height: 1),
              ),
              style: ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                padding: const MaterialStatePropertyAll(
                  EdgeInsets.fromLTRB(8, 2, 16, 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Consumer category() {
    return Consumer(
      builder: (_, wiRef, __) {
        String categorySelected = wiRef.watch(myLaundryCategoryProvider);

        return SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.laundryStatusCategory.length,
            itemBuilder: (context, index) {
              String category = AppConstants.laundryStatusCategory[index];

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 30 : 8,
                  right: index == AppConstants.laundryStatusCategory.length - 1
                      ? 30
                      : 8,
                ),
                child: InkWell(
                  onTap: () {
                    setMyLaundryCategory(ref, category);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: category == categorySelected
                            ? Colors.green
                            : Colors.grey[400]!,
                      ),
                      color: category == categorySelected
                          ? Colors.green
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        height: 1,
                        color: category == categorySelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
