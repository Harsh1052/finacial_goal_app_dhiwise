import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finacial_goal_app/extensions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final collectionStream =
      FirebaseFirestore.instance.collection('financial_goal_data').snapshots();
  List<Color> rangeColors = <Color>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF2d2c75),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot>(
                stream: collectionStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final data =
                      snapshot.data!.docs[0].data() as Map<String, dynamic>;
                  getRangeColors(data['contributions'].length);

                  return Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Buy a dream house',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ).paddingSymmetric(horizontal: 24),
                      Transform.scale(
                        scale: 1,
                        child: SfRadialGauge(
                            enableLoadingAnimation: true,
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum:
                                    (data['target_amount'] as int).toDouble(),
                                showLabels: false,
                                showTicks: false,
                                startAngle: 120,
                                endAngle: 60,
                                radiusFactor: 0.8,
                                axisLineStyle: const AxisLineStyle(
                                  thickness: 0.05,
                                  cornerStyle: CornerStyle.bothCurve,
                                  color: Color(0XFF7a7ba5),
                                  thicknessUnit: GaugeSizeUnit.factor,
                                ),
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    widget: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.home,
                                          color: Colors.white,
                                          size: 100,
                                        ),
                                        Text(
                                          '\$${data['saved_amount']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium!
                                              .copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        Text(
                                          'You saved',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium!
                                              .copyWith(
                                                fontSize: 20,
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                              ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                pointers: <GaugePointer>[
                                  RangePointer(
                                    cornerStyle: CornerStyle.bothCurve,
                                    value: (data['saved_amount'] as int)
                                        .toDouble(),
                                    width: 0.05,
                                    sizeUnit: GaugeSizeUnit.factor,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ]),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            5,
                            (index) => Container(
                                  margin: const EdgeInsets.all(3),
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == 0
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                )),
                      ).paddingSymmetric(horizontal: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Goal"),
                              Text(
                                  "by ${convertTimeStampToDate(data['due_date'])}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.white.withOpacity(0.5),
                                      ))
                            ],
                          ),
                          Text("\$${formatDollarPrice(data['target_amount'])}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.white,
                                  )),
                        ],
                      ).paddingSymmetric(vertical: 20, horizontal: 24),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 8),
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0XFF3a6ae2),
                        ),
                        child: Column(
                          children: List.generate(
                              data['suggestions'].length,
                              (index) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text((data['suggestions'][index]
                                                as Map<String, dynamic>)
                                            .keys
                                            .first),
                                        Text(
                                            '\$${(data['suggestions'][index] as Map<String, dynamic>).values.first}')
                                      ])),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Contributions',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.black),
                                  ),
                                  Text(
                                    'show histroy',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.black),
                                  )
                                ]).paddingSymmetric(vertical: 10),
                            SizedBox(
                                height: 10,
                                width: double.infinity,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Row(
                                      children: List.generate(
                                        rangeColors.length,
                                        (index) {
                                          double containerWidth =
                                              (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      40) *
                                                  (getPercentage(
                                                      data['saved_amount'],
                                                      (data['contributions']
                                                                  [index]
                                                              as Map<String,
                                                                  dynamic>)
                                                          .values
                                                          .first));

                                          return Container(
                                              width: containerWidth,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: rangeColors[index],
                                              ));
                                        },
                                      ),
                                    ))),
                            Column(
                              children: List.generate(
                                  data['contributions'].length,
                                  (index) => Row(children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 3),
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: rangeColors[index],
                                          ),
                                        ),
                                        Text(
                                            (data['contributions'][index]
                                                    as Map<String, dynamic>)
                                                .keys
                                                .first,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: Colors.black)),
                                        const Spacer(),
                                        Text(
                                            '\$${(data['contributions'][index] as Map<String, dynamic>).values.first}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: Colors.black))
                                      ]).paddingSymmetric(vertical: 2)),
                            ).paddingSymmetric(vertical: 20),
                          ],
                        ),
                      )
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

  //convert timestamp to date like Jan 2021
  String convertTimeStampToDate(Timestamp timeStamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(timeStamp.millisecondsSinceEpoch);
    // convert month number to name

    return '${getMonthName(date.month)} ${date.year}';
  }

  double getPercentage(int savedAmount, int targetAmount) {
    return (targetAmount / savedAmount);
  }

  // generate new colors
  getRangeColors(int length) {
    rangeColors.clear();
    for (int i = 0; i < length; i++) {
      rangeColors.add(Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
          .withOpacity(1.0));
    }
  }

  // convert month number to name
  String getMonthName(int monthNumber) {
    switch (monthNumber) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      default:
        return 'Dec';
    }
  }

  // formate dollar price by ',' and '.'
  String formatDollarPrice(num price) {
    String priceString = price.toStringAsFixed(0);
    String formatedPrice = '';
    int counter = 0;
    for (int i = priceString.length - 1; i >= 0; i--) {
      counter++;
      formatedPrice = priceString[i] + formatedPrice;
      if (counter == 3 && i != 0) {
        formatedPrice = ',$formatedPrice';
        counter = 0;
      }
    }
    return formatedPrice;
  }
}
