import 'package:flutter/material.dart';


class ContentPages extends StatefulWidget {

  final double width;
  final double height;
  final double fontSize;
  final String content;

  ContentPages({
    required this.width,
    required this.height,
    required this.fontSize,
    required this.content,
  });

  @override
  _ContentPagesState createState() => _ContentPagesState();
}

class _ContentPagesState extends State<ContentPages> {
  late int totalPages;
  late int currentPage;
  late List<String> pageContent;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    pageContent = _splitContentIntoPages();
    totalPages = pageContent.length;
  }

  List<String> _splitContentIntoPages() {
    List<String> pages = [];
    int maxCharsPerPage =
        ((widget.width ~/ widget.fontSize) * (widget.height ~/ widget.fontSize)) ~/
            2; // assuming average length of a Korean character is 2
    String remainingContent = widget.content;

    while (remainingContent.isNotEmpty) {
      if (remainingContent.length <= maxCharsPerPage) {
        pages.add(remainingContent);
        remainingContent = '';
      } else {
        String currentPageContent =
        remainingContent.substring(0, maxCharsPerPage);
        int lastSpaceIndex = currentPageContent.lastIndexOf(' ');
        if (lastSpaceIndex != -1) {
          currentPageContent = currentPageContent.substring(0, lastSpaceIndex);
        }
        pages.add(currentPageContent);
        remainingContent =
            remainingContent.substring(currentPageContent.length).trimLeft();
      }
    }

    return pages;
  }

  void nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
      _pageController.animateToPage(
        currentPage - 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      _pageController.animateToPage(
        currentPage - 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$currentPage/$totalPages',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            itemBuilder: (context, index) {
              return Container(
                width: widget.width,
                height: widget.height,
                padding: EdgeInsets.all(16.0),
                child: Text(
                  pageContent[index],
                  style: TextStyle(fontSize: widget.fontSize),
                ),
              );
            },
            onPageChanged: (index) {
              setState(() {
                currentPage = index + 1;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: previousPage,
              child: Icon(Icons.arrow_back),
            ),
            SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: nextPage,
              child: Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ],
    );
  }
}