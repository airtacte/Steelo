import React, { createContext, useReducer } from 'react';

const initialState = {}; // Define your initial state
const Store = createContext(initialState);

const reducer = (state, action) => {
  // Handle your global state changes
};

export const StoreProvider = ({ children }) => {
  const [state, dispatch] = useReducer(reducer, initialState);

  return (
    <Store.Provider value={{ state, dispatch }}>
      {children}
    </Store.Provider>
  );
}

export default Store;
