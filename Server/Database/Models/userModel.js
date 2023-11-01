'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    static associate(models) {
      // define association here if needed
    }
  }
  User.init({
    firstName: DataTypes.STRING,
    lastName: DataTypes.STRING,
    email: DataTypes.STRING,
    age: DataTypes.INTEGER,
    address: DataTypes.STRING,
    gender: DataTypes.STRING,
    bankDetails: DataTypes.JSON, // Storing as JSON, consider encryption for security
    kycStatus: DataTypes.BOOLEAN,
    stakingPosition: DataTypes.FLOAT,  // or DataTypes.DECIMAL for precision
    preferences: DataTypes.ARRAY(DataTypes.STRING),  // User preferences based on content they engage with
    interactionPatterns: {
        type: DataTypes.JSON, 
        allowNull: false,
        defaultValue: {},
        get() {
            return JSON.parse(this.getDataValue('interactionPatterns'));
        },
        set(val) {
            this.setDataValue('interactionPatterns', JSON.stringify(val));
        }
    }
  }, {
    sequelize,
    modelName: 'User',
  });
  return User;
};
