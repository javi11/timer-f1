import { History } from 'history';
import React from 'react';
import {
	IonBackButton,
	IonButton,
	IonButtons,
	IonContent,
	IonHeader,
	IonIcon,
	IonTitle,
	IonToolbar
} from '@ionic/react';

interface ItemProps {
  history: History;
}

const Home: React.SFC<ItemProps> = ({ history }) => {
  function goToLink(e: MouseEvent) {
    if (!e.currentTarget) {
      return;
    }
    e.preventDefault();
    history.push((e.currentTarget as HTMLAnchorElement).href);
  }
  return (
    <>
      <IonHeader>
        <IonToolbar color="primary">
          <IonButtons slot="start">
            <IonBackButton goBack={() => {}} />
          </IonButtons>
          <IonTitle>Timmer</IonTitle>
          <IonButtons slot="end">
            <IonButton href="/create-plane" routerDirection="forward" onClick={goToLink}>
              <IonIcon slot="icon-only" name="add-circle-outline" />
            </IonButton>
          </IonButtons>
        </IonToolbar>
      </IonHeader>

      <IonContent />
    </>
  );
};

export default Home;
