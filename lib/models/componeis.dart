// @dart=2.9
class Componies {
  final String id;
  final String componyName;
  final String openTime;
  final String closeTime;
  final String date;
  final String open;
  final String close;
  final String openPatti;
  final String closePatti;
  final String bidCount;
  final bool isPlay;
  final String type;
  final DateTime utcOpenTime;
  final DateTime utcCloseTime;
  final bool isCommingSoon;

  Componies({
    this.id,
    this.componyName,
    this.openTime,
    this.closeTime,
    this.date,
    this.open,
    this.close,
    this.openPatti,
    this.closePatti,
    this.bidCount,
    this.isPlay,
    this.type,
    this.utcCloseTime,
    this.utcOpenTime,
    this.isCommingSoon =false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'componyName': componyName,
      'openTime': openTime,
      'closeTime': closeTime,
      'date': date,
      'open': open,
      'close': close,
      'openPatti': openPatti,
      'closePatti': closePatti,
      'bidCount': bidCount,
      'isPlay': isPlay,
      'type': type,
      "isCommingSoon":isCommingSoon
    };
  }
}
