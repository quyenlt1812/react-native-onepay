import React, { FC, useEffect, useState } from 'react';
import { Dimensions, SafeAreaView, StyleSheet, View } from 'react-native';
import OnepayHash from 'react-native-onepay-hash';
import WebView from 'react-native-webview';

const App: FC = () => {
  const [result, setResult] = useState<string>();

  useEffect(() => {
    OnepayHash.generateURL({
      version: '2',
      command: 'pay',
      accessCode: '6BEB2546',
      merchant: 'TESTONEPAY',
      locale: 'en',
      returnUrl: 'https://localhost/returnurl',
      orderInfo: '123214125125',
      amount: '1000000',
      title: 'Test Payment',
      currency: 'VND',
      secretKey: '6D0870CDE5F24F34F3915FB0045120DB',
      baseUrl: 'https://mtf.onepay.vn/',
      merchTxnRef: new Date().getTime().toString(),
      againLink: 'https://scanme.eastplayers.io/cancel-payment',
      cardList: 'INTERNATIONAL',
    }).then((res) => setResult(res));
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.container}>
        {result && (
          <WebView
            source={{ uri: result }}
            style={{
              width: Dimensions.get('window').width,
              height: Dimensions.get('window').height,
            }}
          />
        )}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});

export default App;
