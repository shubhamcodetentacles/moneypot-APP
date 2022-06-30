// @dart=2.9
class Transaction {
  final String transacionId;
  final String transacioName;
  final String date;
  final String amount;
  final String previousAmount;
  final bool isAdd;
  final bool isCommission;

  Transaction({
    this.transacionId,
    this.transacioName,
    this.date,
    this.amount,
    this.previousAmount,
    this.isAdd,
    this.isCommission,
  });
}
