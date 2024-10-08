// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_flutter_package/model/article.dart';

// Project imports:
import 'package:flutter_showcase_riverpod/config.dart';
import 'package:flutter_showcase_riverpod/provider/news.dart';
import '../../utils/date.dart';
import '../../utils/url_launch.dart';
import '../basic_section_wrapper.dart';

class NewsFeed extends StatelessWidget {
  final NewsCountry? country;

  const NewsFeed({super.key, this.country});

  @override
  Widget build(BuildContext context) {
    return BasicSectionWrapper(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (country != null) ...[
          Text('${country!.fullname} Top Headlines',
              style: AppTextStyle.pageTitle),
          const SizedBox(height: 16),
          NewsList(country: country),
        ] else ...[
          Text('BBC Top Headlines', style: AppTextStyle.pageTitle),
          const SizedBox(height: 16),
          const NewsList()
        ]
      ],
    ));
  }
}

class NewsList extends ConsumerWidget {
  final NewsCountry? country;

  const NewsList({super.key, this.country});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NewsState newsState = ref.watch(newsProvider);

    if (newsState.needRefetch || newsState.lastFetched == null) {
      if (newsState.needRefetch) {
        ref.read(newsProvider.notifier).fetchAllNews();
      }
      return const Center(child: CircularProgressIndicator());
    }
    return NewsListInner(
        articles:
            (country != null ? newsState[country!] : newsState.bbcNews) ?? []);
  }
}

class NewsListInner extends StatelessWidget {
  final List<Article> articles;

  const NewsListInner({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return Wrap(
        runSpacing: 10,
        children: articles.map((a) => NewsTile(article: a)).toList());
  }
}

class NewsTile extends StatelessWidget {
  final Article article;

  const NewsTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final DateTime pubDate =
        DateTime.tryParse(article.publishedAt ?? '') ?? DateTime.now();
    return GestureDetector(
      onTap: () {
        if (article.url == null) return;
        launchUrl(article.url!);
      },
      child: Column(children: [
        Text(article.title ?? '', style: AppTextStyle.titleTight),
        if (article.content != null)
          Text(article.content!, style: AppTextStyle.bodyTight),
        if (article.author != null)
          Row(children: [
            const Spacer(),
            Text('${formatDateAgo(pubDate)} · ${article.author!}',
                style: AppTextStyle.strong)
          ])
      ]),
    );
  }
}
