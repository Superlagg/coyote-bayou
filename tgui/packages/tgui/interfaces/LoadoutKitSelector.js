import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, LabeledList, Section, Stack} from '../components';
import { Window } from '../layouts';
import { IconStack } from '../components/Icon';
const LoadoutHeadfootHeight = 40;

export const LoadoutKitMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    CurrentCategory,
  } = data;

  return (
    <Window
      title="Kit Shopping!"
      width={800}
      height={600}>
      <Window.Content>
        <Section>
          <Stack fill vertical>
            <Stack.Item>
              <LoadoutHeader />
            </Stack.Item>
            <Stack.Item grow>
              <Flex
                direction="row"
                height="100%">
                <Flex.Item basis="45%">
                  {!!CurrentCategory ? <LoadoutCategories /> : <LoadoutKits />};
                </Flex.Item>
                <Flex.Item basis="45%">
                  <LoadoutKitDetails />
                </Flex.Item>
              </Flex>
            </Stack.Item>
            <Stack.Item>
              <LoadoutFooter />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const LoadoutHeader = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    KitName,
  } = data;

  return (
    <Box height={LoadoutHeadfootHeight}>
      <Flex
        direction="row"
        height="100%">
        <Flex.Item grow={1}>
          <Box bold>
            {KitName}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <LoadoutCoinDisplay />
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const LoadoutCoinDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    Coins = [],
  } = data;
  if(!Coins.length) {
    return (<Box>Bye!</Box>);
  };
  return (
    <Box
      height="100%"
      width="fit-content">
      <Flex height="100%">
        {Coins.map((coin, index) => (
        <Flex.Item>
          <Box key={index}>
            <LovelyCoin coin={coin} />
          </Box>
        </Flex.Item>
        ))}
      </Flex>
    </Box>
  );
};

const LovelyCoin = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    coin,
    purchase,
  } = props;
  const {
    coin_name,
    coin_awesome_icon,
    coin_color,
    coin_tooltip,
  } = coin;
  let isDisabled = !!purchase && !checkHasCoin(coin);
  return (
    <Button
      title ={coin_name}
      width="fit-content"
      height="fit-content"
      color="transparent"
      tooltip={coin_tooltip}
      tooltipPosition="bottom"
      disabled={isDisabled}
      onClick={!!purchase && act('BuyLoadout', {
        CoinToSpend: coin,
        BuyKey: purchase,
      })} >
      <IconStack>
        <Icon
          name="fa-solid fa-circle"
          color={coin_color}
          size={1.5} />
        <Icon
          name={coin_awesome_icon}
          color="#000000" />
      </IconStack>
    </Button>
  );
};

// Takes in a coin in its props, and checks if the player has it, returning true or false depending on the result.
const checkHasCoin = (coin) => {
  const { act, data } = useBackend(context);
  const {
    coin_name,
  } = coin;
  const {
    Coins = [],
  } = data;
  if (!Coins.length) {
    return false;
  };
  for (let i = 0; i < Coins.length; i++) {
    if (Coins[i].coin_name === coin_name) {
      return true;
    };
  };
  return false;
}

const LoadoutCategories = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    AllCategories,
  } = data;
  if(!AllCategories.length) {
    return (<Box>Haha, cool categorie, Mark!</Box>);
  };

  return (
    <Section
      title="Categories"
      height="100%">
      <Box
        height="100%"
        fluid
        scrollable>
        <Stack fill vertical>
          {AllCategories.map(category => (
            <Stack.Item grow key={index}>
              <Button
                fluid
                textAlign="left"
                onClick={() => act('SetCategory', {
                  KitCategory: category,
                })}
                content={category} />
            </Stack.Item>
          ))}
        </Stack>
      </Box>
    </Section>
  );
};

// Displays a list of kits in the current category.
const LoadoutKits = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    // Array format: ["Category1" : ["name" : ["kit_name" : "name", "kit_price" : ["coin1", "coin2"], ["kit_contents" : ["item1", "item2"]]]], "Category2" : ["name" : ["kit_name" : "name", "kit_price" : ["coin1", "coin2"], ["kit_contents" : ["item1", "item2"]]]]], ...]
    LoadoutTable,
  } = data;
  if(!LoadoutTable.length) {
    return (<Box>Haha, cool loadoute, Mark!</Box>);
  };
  return (
    <Section
      title="Kits"
      height="100%">
      <Button
        position="absolute"
        top={0}
        right={0}
        icon="arrow-left"
        tooltip="Return to categories"
        tooltipPosition="bottom"
        content="Return"
        onClick={() => act('ClearCategory')} />
      <Box
        height="100%"
        fluid
        scrollable>
        <Stack fill vertical>
          {LoadoutTable.map((kit, index) => (
            <Stack.Item grow key={index}>
              <Button
                fluid
                textAlign="left"
                onClick={() => act('SetLoadout', {
                  kit: kit,
                })}>
                <Flex
                  direction="row"
                  height="100%">
                  <Flex.Item grow={1}>
                    <Box bold>
                      {kit.kit_name}
                    </Box>
                  </Flex.Item>
                  <Flex.Item>
                    {kit.kit_cost.map((coin, index) => (
                      <Box
                        key={index}
                        width="fit-content"
                        bold>
                          <LovelyCoin coin={coin} />
                      </Box>
                    ))}
                  </Flex.Item>
                </Flex>
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Box>
    </Section>
  );
}

// Displays the contents of the selected kit.
const LoadoutKitDetails = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    // Array format: ["Category1" : ["name" : ["kit_name" : "name", "kit_price" : ["coin1", "coin2"], ["kit_contents" : ["item1", "item2"]]]], "Category2" : ["name" : ["kit_name" : "name", "kit_price" : ["coin1", "coin2"], ["kit_contents" : ["item1", "item2"]]]]], ...]
    LoadoutTable,
    /// the ["name"] in the array above
    CurrentLoadout,
  } = data;
  if(!LoadoutTable.length || !CurrentLoadout) {
    return (<Box>Haha, cool kitten, Mark!</Box>);
  };
  let MyKit = LoadoutTable[CurrentLoadout]; // ["name" : ["kit_name" : "name", "kit_price" : ["coin1", "coin2"], ["kit_contents" : ["item1", "item2"]]]]
  let KitName = MyKit.kit_name; // String -- also the key for the kit in the LoadoutTable
  let KitDetails = MyKit.kit_contents; // [["item_name", "item_desc"], ["item_name", "item_desc"], ...
  let KitPrice = MyKit.kit_cost ; // Array of coin data objects

  return (
    <Section
      title={KitName}
      height="100%">
      <Stack fill vertical>
        <Stack.Item grow>
          <Box
            height="100%"
            fluid
            scrollable>
            <LabeledList labelPosition="left">
              {KitDetails.map((item, index) => (
                <LabeledList.Item key={index}>
                  <LabeledList key={index}>
                    <LabeledList.Item label={item[0]} />
                    <LabeledList.Item label={item[1]} />
                    <LabeledList.Divider />
                  </LabeledList>
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Section
            width="100%"
            height = "fit-content">
            <Flex direction="row">
              <Flex.Item shrink={1}>
                <Box bold>
                  Purchase With:
                </Box>
              </Flex.Item>
              <Flex.Item>
                {KitPrice.map((coin, index) => (
                  <Box
                    key={index}
                    width="fit-content"
                    bold>
                      <LovelyCoin coin={coin} purchase={KitName}/>
                  </Box>
                ))}
              </Flex.Item>
            </Flex>
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            icon="arrow-left"
            content="Return"
            onClick={() => act('ClearLoadout')} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
