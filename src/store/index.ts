import { createStore } from 'react-hooks-global-state';
import { reducer } from './reducer';

const initialState = {
  planes: []
};

export const { GlobalStateProvider, dispatch, useGlobalState } = createStore(reducer, initialState);
