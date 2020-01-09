import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nastik_trip/shared/shared.dart';
import 'article.service.dart';
import 'article_editor.dart';
import 'article_detail.dart';

class ArticleList extends StatefulWidget {
  static const String routeName = 'article-list';

  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  final ArticleService _articleService = ArticleService();

  List<Article> _articles;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      appBar: SAppBar(
        label: 'Статьи',
      ),
      body: _body$(context),
      floatingActionButton: _fab$(context),
      margin: EdgeInsets.all(0),
    );
  }

  Widget _body$(BuildContext context) {
    if (_articles == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (_, int index) {
        return _item$(
          context: context,
          article: _articles[index],
        );
      },
    );
  }

  Widget _item$({
    BuildContext context,
    Article article,
  }) {
    final ThemeData theme = Theme.of(context);

    return Slidable(
      key: Key('${article.id}'),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () {
          Navigate.push(
            context: context,
            widget: ArticleDetail(
              onSubmit: (Article updated) {
                _load();
              },
              article: article,
            ),
          );
        },
        onLongPress: () {
          _edit(context, article);
        },
        child: DataItem(
          title: article.title,
          subtitle: article.content.split('\n').elementAt(0),
          titleStyle: theme.textTheme.title,
          subtitleStyle: theme.textTheme.body2.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          onTap: () {
            _delete(article);
          },
          caption: 'Удалить',
          color: Colors.red,
          icon: Icons.delete,
        ),
      ],
    );
  }

  Widget _fab$(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _edit(context, null);
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.lightBlueAccent,
    );
  }

  Future _load() async {
    final List<Article> articles = await _articleService.get();

    setState(() {
      _articles = articles;
    });
  }

  void _edit(BuildContext context, Article article) {
    Navigate.push(
      context: context,
      widget: ArticleEditor(
        onSubmit: (Article article) async {
          await _articleService.save(article);
          Navigator.of(context).pop();
          _load();
        },
        newId: _articles.length == 0 ? 1 : _articles.last.id + 1,
        article: article,
      ),
    );
  }

  void _delete(Article article) {
    _articleService.delete(article.id);
    setState(() {
      _articles.remove(article);
    });
  }
}
