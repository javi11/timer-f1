import React from 'react';
import { RouteComponentProps } from 'react-router';
import {
	IonBackButton,
	IonButtons,
	IonContent,
	IonHeader,
	IonTitle,
	IonToolbar
} from '@ionic/react';

type Props = RouteComponentProps<{ id: string; tab: string }> & {
  goBack: () => void;
};

const Plane: React.SFC<Props> = ({ match }) => (
  <>
    <IonHeader>
      <IonToolbar>
        <IonButtons slot="start">
          <IonBackButton goBack={() => {}} />
        </IonButtons>
        <IonTitle>My Navigation Bar</IonTitle>
      </IonToolbar>

      <IonToolbar>
        <IonTitle>{match.params.id}</IonTitle>
      </IonToolbar>
    </IonHeader>

    <IonContent />
  </>
);

export default Plane;
