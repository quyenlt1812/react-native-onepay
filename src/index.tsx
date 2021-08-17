import { NativeModules } from 'react-native';

type OnepayHashType = {
  multiply(a: number, b: number): Promise<number>;
};

const { OnepayHash } = NativeModules;

export default OnepayHash as OnepayHashType;
