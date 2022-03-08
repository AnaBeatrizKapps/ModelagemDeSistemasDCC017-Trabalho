import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartdingdong/models/history_item_model.dart';
import 'package:intl/intl.dart';

class HistoryItemCell extends StatelessWidget {
  final HistoryItemModel historyItem;

  HistoryItemCell({this.historyItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: ShapeDecoration(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                historyItem.incomingUser != null
                    ? historyItem.incomingUser
                    : "Anônimo",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: historyItem.status == CallStatus.accepted
                      ? Colors.black
                      : Colors.red,
                ),
              ),
              Spacer(),
              Text(
                _callTime(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.4),
                ),
              )
            ],
          ),
          historyItem.message != null && historyItem.message.isNotEmpty
              ? _buildMessage()
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Column(
      children: [
        SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.bubble_left_fill,
              size: 17,
              color: Colors.black.withOpacity(0.5),
            ),
            SizedBox(width: 8),
            Text(
              historyItem.message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _callTime() {
    var formatted =
        DateFormat(DateFormat.HOUR24_MINUTE).format(historyItem.createdAt);
    return formatted;
  }

  String formatDateFromTimestamp({DateTime date}) {
    var formattedDate = DateFormat.yMMMMEEEEd().add_Hm().format(date);
    return formattedDate;
  }
}
