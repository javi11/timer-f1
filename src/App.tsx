import '@ionic/core/css/core.css';
import '@ionic/core/css/ionic.bundle.css';
import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import { IonApp, IonPage } from '@ionic/react';
import CreatePlane from './pages/CreatePlane';
import Home from './pages/Home';
import Plane from './pages/Plane';
import { GlobalStateProvider } from './store';

const App: React.FC = () => {
  return (
    <GlobalStateProvider>
      <Router>
        <div id="app">
          <IonApp>
            <IonPage id="main">
              <Switch>
                <Route path="/" component={Home} exact={true} />
                <Route path="/planes/:id" component={Plane} />
                <Route path="/create-plane" component={CreatePlane} />
              </Switch>
            </IonPage>
          </IonApp>
        </div>
      </Router>
    </GlobalStateProvider>
  );
};

export default App;
