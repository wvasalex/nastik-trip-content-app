import 'package:flutter/material.dart';
import 'package:nastik_trip/shared/shared.dart';
import 'article_editor.dart';
import 'article.service.dart';

class ArticleDetail extends StatefulWidget {
  final Article article;
  final Function(Article) onSubmit;

  ArticleDetail({
    @required this.article,
    @required this.onSubmit,
  });

  @override
  _ArticleDetailState createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  final ArticleService _articleService = ArticleService();

  Article article;

  @override
  void initState() {
    article = widget.article;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      appBar: SAppBar(
        label: article.title,
        back: true,
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
      body: SingleChildScrollView(
        child: _body$(context),
      ),
      floatingActionButton: _fab$(context),
      margin: EdgeInsets.all(0),
    );
  }

  Widget _body$(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasDescription = (article.description ?? '').trim().length > 0;
    final List<Widget> content = hasDescription
        ? [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${article.description}',
                style: theme.textTheme.body1.copyWith(
                  color: Colors.black.withOpacity(.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ]
        : [];
    content.addAll(article.getContent());
    content.add(SizedBox(height: 24));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }

  Widget _fab$(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _edit(context);
      },
      child: Icon(Icons.edit),
      backgroundColor: Colors.red,
    );
  }

  void _edit(BuildContext context) {
    Navigate.push(
      context: context,
      widget: ArticleEditor(
        onSubmit: (Article updated) async {
          await _articleService.save(updated);
          widget.onSubmit(updated);
          Navigator.of(context).pop();

          article = await _articleService.getById(updated.id);
          setState(() {});
        },
        article: article,
      ),
    );
  }
}
