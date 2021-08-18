import * as React from 'react';
import { Dimensions, SafeAreaView, StyleSheet, View } from 'react-native';
import OnepayHash from 'react-native-onepay-hash';
import WebView from 'react-native-webview';

export default function App() {
  const [result, setResult] = React.useState<string>();
  console.log('🚀 ~ file: App.tsx ~ line 8 ~ App ~ result', result);

  React.useEffect(() => {
    OnepayHash.generateURL(
      '2',
      'pay',
      '6BEB2546',
      'TESTONEPAY',
      'en',
      'https://localhost/returnurl',
      '123214125125',
      '1000000',
      'Test Payment',
      'VND',
      '6D0870CDE5F24F34F3915FB0045120DB',
      'https://mtf.onepay.vn/paygate/vpcpay.op?',
      new Date().getTime().toString()
    ).then((res) => setResult(res));
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.container}>
        {/* <Text>Haha: {result}</Text> */}
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
}

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
