import { Action } from './actions';

export const reducer = (state: any, action: Action) => {
  switch (action.type) {
    case 'addPlane':
      return { ...state, planes: [...state.planes, action.plane] };
    default:
      return state;
  }
};
