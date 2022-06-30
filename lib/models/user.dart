// @dart=2.9
class User {
  String name;
  String email;
  String mobileNo;
  String walletAmount;

  set userName(String name) {
    name = name;
  }

  set userEmail(String email) {
    email = email;
  }

  set userMobileNo(String mobileNo) {
    mobileNo = mobileNo;
  }

  set userWalletAmount(String walletAmount) {
    walletAmount = walletAmount;
  }

  Map<String, dynamic> get userData {
    return {
      "name": name,
      "email": email,
      "mobileNo": mobileNo,
      "walletAmount": walletAmount,
    };
  }

  User({
    this.name,
    this.email,
    this.mobileNo,
    this.walletAmount,
  });
}
