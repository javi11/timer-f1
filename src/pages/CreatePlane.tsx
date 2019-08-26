import React from 'react';
import { RouteComponentProps } from 'react-router';
import {
	IonBackButton,
	IonButton,
	IonButtons,
	IonContent,
	IonHeader,
	IonInput,
	IonTitle,
	IonToolbar
} from '@ionic/react';

type Props = RouteComponentProps<{ id: string; tab: string }> & {
  goBack: () => void;
};

const CreatePlane: React.SFC<Props> = ({ goBack }) => (
  <>
    <IonHeader>
      <IonToolbar color="primary">
        <IonButtons slot="start">
          <IonBackButton goBack={goBack} defaultHref="/" />
        </IonButtons>
        <IonTitle>Timmer</IonTitle>
      </IonToolbar>
    </IonHeader>

    <IonContent>
      <IonInput placeholder="Plane name" />
      <IonButton title="Create" />
    </IonContent>
  </>
);

export default CreatePlane;
