import 'package:flutter/material.dart';
import '../shared.dart';

class RadioGroupItem {
  final String value;
  final String title;
  final String subtitle;

  RadioGroupItem({
    @required this.value,
    @required this.title,
    this.subtitle,
  });
}

class RadioGroup extends StatefulWidget {
  final List<RadioGroupItem> items;
  final Function(RadioGroupItem) onChange;

  RadioGroup({
    @required this.onChange,
    @required this.items,
  });

  @override
  _RadioGroupState createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  String _value = '-1';

  @override
  Widget build(BuildContext context) {
    var items$ = widget.items.map(_item$).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items$,
    );
  }

  Widget _item$(RadioGroupItem item) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        _check(item);
      },
      child: DataItem(
        leading: RoundCheckbox(
          onChange: () {
            _check(item);
          },
          checked: _value == item.value,
          size: 20,
        ),
        title: item.title,
        subtitle: item.subtitle,
        titleStyle: theme.textTheme.title,
        subtitleStyle: theme.textTheme.body2,
        underline: false,
        padding: 0,
        innerPadding: EdgeInsets.all(6),
      ),
    );
  }

  void _check(RadioGroupItem item) {
    setState(() {
      _value = item.value;
      widget.onChange(item);
    });
  }
}
