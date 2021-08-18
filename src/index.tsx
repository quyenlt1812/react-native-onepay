import { NativeModules } from 'react-native';

type OnepayHashType = {
  multiply(a: number, b: number): Promise<number>;
  generateURL(
    version: string,
    command: string,
    accessCode: string,
    merchant: string,
    locale: string,
    returnUrl: string,
    orderInfo: string,
    amount: string,
    title: string,
    currency: string,
    secretKey: string,
    baseUrl: string,
    merchTxnRef: string
  ): Promise<string>;
};

const { OnepayHash: Onepay } = NativeModules;

export default Onepay as OnepayHashType;
