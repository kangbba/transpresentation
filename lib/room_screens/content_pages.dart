// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../helper/sayne_separator.dart';
//
//
// class ContentPages extends StatefulWidget {
//
//   final double width;
//   final double height;
//   final double fontSize;
//   final String content;
//   final String langCode;
//
//   const ContentPages({super.key,
//     required this.width,
//     required this.height,
//     required this.fontSize,
//     required this.content,
//     required this.langCode,
//   });
//
//   @override
//   _ContentPagesState createState() => _ContentPagesState();
//
// }
//
// class _ContentPagesState extends State<ContentPages> {
//   late int totalPages = 1;
//   late int currentPage = 1;
//   late PageController _pageController;
//   List<String>? pageContent;
//   bool _isAutoScrollEnabled = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     pageContent = _splitContentIntoPages(widget.content);
//     updatePageInfo(false);
//   }
//   @override
//   void didUpdateWidget(ContentPages oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if(widget.langCode != oldWidget.langCode){
//       updatePageInfo(false);
//       toFirstPage();
//     }
//     else if(widget.content != oldWidget.content){
//       updatePageInfo(true);
//     }
//
//     setState(() {
//
//     });
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//
//   updatePageInfo(bool useAutoScroll){
//     pageContent = _splitContentIntoPages(widget.content);
//     if(pageContent == null){
//       totalPages = 1;
//       currentPage = 1;
//     }
//     else{
//       int previousPageCount = totalPages;
//       int newPageCount = pageContent!.length;
//       totalPages = newPageCount > 0 ? newPageCount : 1;
//       if(useAutoScroll){
//         if(newPageCount > previousPageCount){
//           toLastPage();
//         }
//       }
//     }
//   }
//   static const double lineSpacing = 1.3;
//
//   List<String>? _splitContentIntoPages(String content) {
//     if (content.isEmpty) {
//       return null;
//     }
//     List<String> pages = [];
//     double lineHeight = widget.fontSize * lineSpacing;
//     int maxCharsPerLine = (widget.width ~/ widget.fontSize).toInt();
//     int maxLinesPerPage = (widget.height ~/ lineHeight).toInt();
//     int maxCharsPerPage = maxCharsPerLine * maxLinesPerPage;
//
//     String remainingContent = widget.content;
//
//     while (remainingContent.isNotEmpty) {
//       if (remainingContent.length <= maxCharsPerPage) {
//         pages.add(remainingContent);
//         remainingContent = '';
//       } else {
//         String currentPageContent =
//         remainingContent.substring(0, maxCharsPerPage);
//         int lastSpaceIndex = currentPageContent.lastIndexOf(' ');
//         if (lastSpaceIndex != -1) {
//           currentPageContent = currentPageContent.substring(0, lastSpaceIndex);
//         }
//         pages.add(currentPageContent);
//         remainingContent =
//             remainingContent.substring(currentPageContent.length).trimLeft();
//       }
//     }
//
//     return pages;
//   }
//   void nextPage() {
//     int targetPage = currentPage + 1;
//     if (targetPage <= totalPages) {
//       _pageController.animateToPage(
//         targetPage - 1,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.ease,
//       );
//     }
//   }
//
//   void previousPage() {
//     int targetPage = currentPage - 1;
//     if (targetPage >= 1) {
//       _pageController.animateToPage(
//         targetPage - 1,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.ease,
//       );
//       currentPage = targetPage;
//     }
//   }
//
//   void toLastPage() {
//     int targetPage = totalPages;
//     if (targetPage >= 1) {
//       _pageController.animateToPage(
//         targetPage - 1,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.ease,
//       );
//       currentPage = targetPage;
//     }
//   }
//
//   void toFirstPage() {
//     int targetPage = 1;
//     if (targetPage <= totalPages) {
//       _pageController.animateToPage(
//         targetPage - 1,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.ease,
//       );
//       currentPage = targetPage;
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     if(pageContent == null){
//       return Container();
//     }
//     return Column(
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center, // 수정
//           mainAxisAlignment: MainAxisAlignment.end, // 수정
//           children: [
//             const Text("자동 스크롤 켜기 : ", textAlign: TextAlign.center,),
//             Transform.scale(
//               scaleX: 0.87,
//               scaleY: 0.85,
//               child: CupertinoSwitch(
//                 value: _isAutoScrollEnabled,
//                 onChanged: (value) {
//                   setState(() {
//                     _isAutoScrollEnabled = value;
//                   });
//                 },
//               ),
//             ),
//           ],
//         ),
//         const SayneSeparator(color: Colors.black45, height: 0.3, top: 2, bottom: 2),
//         Expanded(
//           child: Stack(
//             children: [
//               Container(
//                 color: Colors.grey[100],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Container(
//                   color: Colors.grey[100],
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: PageView.builder(
//                           controller: _pageController,
//                           itemCount: totalPages,
//                           itemBuilder: (context, index) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(horizontal : 16.0),
//                               child: Container(
//                                 width: widget.width,
//                                 height: widget.height,
//                                 child: Text(
//                                   pageContent![index],
//                                   style: TextStyle(fontSize: widget.fontSize, color: Colors.black87, height: lineSpacing),
//                                 ),
//                               ),
//                             );
//                           },
//                           onPageChanged: (index) {
//                             setState(() {
//                               currentPage = index + 1;
//                             });
//                           },
//                         ),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CupertinoButton(
//                             onPressed: previousPage,
//                             child: Icon(CupertinoIcons.back),
//                           ),
//                           Text(
//                             '$currentPage/$totalPages',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           CupertinoButton(
//                             onPressed: nextPage,
//                             child: Icon(CupertinoIcons.forward),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SayneSeparator(color: Colors.black45, height: 0.3, top: 2, bottom: 2),
//       ],
//     );
//   }
// }