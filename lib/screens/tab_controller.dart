import 'package:flutter/material.dart';
import 'package:news_app/models/NewsDataModel.dart';
import 'package:news_app/providers/change_body_provider.dart';
import 'package:news_app/providers/selceted_item_provider.dart';
import 'package:news_app/screens/news_details_screen.dart';
import 'package:news_app/screens/tab_item.dart';
import 'package:news_app/shared/network/remote/api_manger.dart';
import 'package:provider/provider.dart';

import '../models/Sources_response.dart';
import 'news_card.dart';

class TabControllerScreen extends StatelessWidget {
  List<Sources> sources;
  late int currentIndex;
  static String? value = '';

  TabControllerScreen(this.sources);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedItemProvider(),
      builder: (context, child) {
        var provider = Provider.of<SelectedItemProvider>(context);
        return Column(
          children: [
            ChangeBodyScreen.parameter == false
                ? DefaultTabController(
                    length: sources.length,
                    child: TabBar(
                        onTap: (value) {
                          provider.SelectedIndex(value);
                        },
                        isScrollable: true,
                        indicatorColor: Colors.transparent,
                        tabs: sources
                            .map((source) => Tab(
                                  child: TabItem(
                                      source,
                                      sources.indexOf(source) ==
                                          provider.selectedIndex),
                                ))
                            .toList()))
                : Text(''),
            FutureBuilder<NewsDataModel>(
              future: ChangeBodyScreen.parameter == false
                  ? ApiManger.getNewsData(
                      sourceId: sources[provider.selectedIndex].id!)
                  : ApiManger.getNewsData(query: value),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.green,
                  ));
                }
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      Text(snapshot.data?.message ?? "Has Error"),
                      TextButton(
                          onPressed: () {}, child: const Text('Try Again'))
                    ],
                  );
                }
                if (snapshot.data?.status != "ok") {
                  return Column(
                    children: [
                      Text(snapshot.data?.message ?? "Has Error"),
                      TextButton(
                          onPressed: () {}, child: const Text('Try Again'))
                    ],
                  );
                }
                var news = snapshot.data?.articles ?? [];
                return Expanded(
                  child: ListView.builder(
                    itemCount: news.length,
                    itemBuilder: (context, index) {
                      currentIndex = index;
                      return NewsCard(news[index]);
                    },
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
