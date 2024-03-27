import React from 'react';
import { FlatList, Animated } from 'react-native';

const BouncyFlatList = Animated.createAnimatedComponent(FlatList);

export default function CreatorsList() {
  return (
    <BouncyFlatList 
      data={yourDataArray}
      renderItem={yourRenderItemFunction}
      // other props
      bounces={true}
    />
  );
}
