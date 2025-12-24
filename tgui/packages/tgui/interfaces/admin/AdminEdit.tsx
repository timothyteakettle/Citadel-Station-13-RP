import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Icon, Input, LabeledList, Section, Tabs } from "../../components";
import { Window } from "../../layouts";


export const AdminEdit = (_properties, context) => {
  const { data } = useBackend(context);
  const {
    authenticated,
    screen,
  } = data;
  return (
    <Window
      width={800}
      height={380}
      resizable>
      <Window.Content>

      </Window.Content>
    </Window>
  );
};
