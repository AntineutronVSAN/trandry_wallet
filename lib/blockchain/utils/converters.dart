


class CryptoMoneyConverter {

  static const String weiCountPerEth = '1000000000000000000';

  static double wei2doubleWithDecimals({int decimals = 5, required BigInt wei}) {
    //wei = BigInt.parse('114634442518999999998');
    //wei = BigInt.parse('114634442518999999998');
    //print('Balance $wei');
    //print(wei.toString());
    var resultString = '0.0';

    final weiString = wei.toString();

    final diff = weiString.length - weiCountPerEth.length;

    if (diff > 0) {
      final leftValueCount = diff + 1;
      final leftValue = weiString.substring(0, leftValueCount);
      final rightValue = weiString.substring(leftValueCount, leftValueCount+decimals);
      resultString = leftValue + '.' + rightValue;

    } else if (diff < 0) {

      final absDiff = -diff;
      if (absDiff < decimals) {

        final zerosCount = absDiff-1;

        resultString = '';
        resultString += '0.';
        resultString += '0'*zerosCount;
        resultString += weiString.substring(0, decimals-absDiff);
      }


    } else {
      resultString = '';
      resultString += weiString[0];
      resultString += '.';
      resultString += weiString.substring(1, decimals);
    }

    /*if (weiString.length > weiCountPerEth.length) {
      final leftValueCount = weiString.length - weiCountPerEth.length + 1;
      final leftValue = weiString.substring(0, leftValueCount);
      final rightValue = weiString.substring(leftValueCount, leftValueCount+decimals);
      resultString = leftValue + '.' + rightValue;

    } else if (weiString.length < weiCountPerEth.length) {

      final diff = weiCountPerEth.length - weiString.length;
      assert(diff > 0);

      if (diff > decimals) {
        resultString = '0.0';
      } else {



      }


    } else {

    }*/

    return double.parse(resultString);
  }

}