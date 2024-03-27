import React from "react";
import { View } from "react-native";
import LottieView from "lottie-react-native";

export default function SplashScreen() {
  return (
    <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
      <LottieView
        source={require("./path_to_your_animation.json")}
        autoPlay
        loop
      />
    </View>
  );
}
