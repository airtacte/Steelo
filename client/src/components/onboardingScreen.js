import React from 'react';
import { View, StyleSheet, Image, Text, TouchableOpacity } from 'react-native';

// Assuming you've set up React Navigation in your project
// Import navigation container and stack navigator in your App.js

function OnboardingScreen({ navigation }) {
  return (
    <View style={styles.container}>
      <Image
        source={require('./path-to-your-background-image.png')} // Use a local image or import from assets
        style={styles.backgroundImage}
      >
        <View style={styles.logoContainer}>
          <Image
            source={require('./path-to-your-logo.png')} // Use a local logo image
            style={styles.logo}
          />
        </View>
        <Text style={styles.welcomeText}>Welcome</Text>
        <TouchableOpacity
          style={styles.button}
          onPress={() => navigation.navigate('Login')} // Assuming 'Login' is the name of your login screen route
        >
          <Text style={styles.buttonText}>Log In</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.button}
          onPress={() => navigation.navigate('Register')} // Assuming 'Register' is the name of your registration screen route
        >
          <Text style={styles.buttonText}>Sign Up</Text>
        </TouchableOpacity>
      </Image>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  backgroundImage: {
    flex: 1,
    width: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoContainer: {
    marginBottom: 50,
  },
  logo: {
    width: 100,
    height: 100,
    resizeMode: 'contain',
  },
  welcomeText: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  button: {
    backgroundColor: '#6200EE',
    paddingVertical: 12,
    paddingHorizontal: 25,
    borderRadius: 25,
    marginVertical: 10,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 18,
  },
});

export default OnboardingScreen;