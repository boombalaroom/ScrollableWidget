import 'package:dev/model/FibonacciModel.dart';
import 'package:flutter/material.dart';

class ScrollablePage extends StatefulWidget {
  const ScrollablePage({super.key});

  @override
  State<ScrollablePage> createState() => _ScrollablePageState();
}

class _ScrollablePageState extends State<ScrollablePage> {
  final List<FibonacciModel> _fibonacciList = [];
  int? indexSelected;
  bool isModalOpen = false;

  @override
  void initState() {
    super.initState();
    _generateFibonacci(41);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _content(),
    );
  }

  _content() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _fibonacciList.length,
                itemBuilder: (context, index) {
                  if (isModalOpen && (indexSelected == index)) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {
                      setState(() => indexSelected = index);
                      _showBottomSheetSelected();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      color: indexSelected == index ? Colors.red : Colors.white,
                      child: Row(
                        children: [
                          Text('Index: ${_fibonacciList[index].index}, Number: ${_fibonacciList[index].number}'),
                          const Spacer(),
                          Icon(
                            _fibonacciList[index].icon,
                            color: Color(0xff48464d),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateFibonacci(int count) {
    for (int i = 0; i < count; i++) {
      FibonacciModel fibonacciValue = FibonacciModel(index: i);
      if (i == 0) {
        fibonacciValue.number = 0;
      } else if (i == 1) {
        fibonacciValue.number = 1;
      } else {
        fibonacciValue.number = _fibonacciList[i - 1].number + _fibonacciList[i - 2].number;
      }

      int remainder = fibonacciValue.number % 3;
      if (remainder == 0) {
        fibonacciValue.icon = Icons.circle;
      } else if (remainder == 1) {
        fibonacciValue.icon = Icons.crop_square;
      } else {
        fibonacciValue.icon = Icons.close;
      }
      _fibonacciList.add(fibonacciValue);
    }
  }

  Future<void> _showBottomSheetSelected() async {
    if (indexSelected == null) return;
    setState(() => isModalOpen = true);
    IconData? iconSelected = _fibonacciList[indexSelected!].icon;
    final listDataFilter = _fibonacciList
        .where((element) => element.icon == iconSelected)
        .toList();
    List<GlobalKey> keys = List.generate(listDataFilter.length, (index) => GlobalKey());

    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Scrollable.ensureVisible(keys[_getIndexHighlight(listDataFilter)].currentContext!);
        });

        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(listDataFilter.length, (index) {
                final dataDisplay = listDataFilter[index];
                final isHighlight = dataDisplay.index == indexSelected!;

                return Container(
                  key: keys[index],
                  color: isHighlight ? Color(0XFF4bae4f) : Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Number: ${dataDisplay.number}'),
                          Text(
                            'Index: ${dataDisplay.index}',
                            style:
                            TextStyle(fontSize: 12, color: Color(0Xff565656)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        dataDisplay.icon,
                        color: Color(0xff48464d),
                      )
                    ],
                  ),
                );
              }),
            ),
          )
        );
      },
    );
    setState(() => isModalOpen = false);
  }

  int _getIndexHighlight(List<FibonacciModel> listDataFilter) {
    return listDataFilter.indexWhere((element) => element.index == indexSelected);
  }
}
