/* eslint-disable max-len */
import { useBackend } from "../backend";
import { Box, Button, Flex, Icon, Section, Stack, ProgressBar } from "../components";
import { Window } from "../layouts";
import { marked } from 'marked';
import { sanitizeText } from '../sanitize';
const AF_HeadSize = "4em";
const AF_EntrySize = "2em";

export const ArtifactFinder = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={400} height={600} theme="hackerman" resizable>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <ArtFinderHead />
          </Stack.Item>
          <Stack.Item grow shrink>
            <Section fill scrollable>
              <ArtFinderEntries />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <ArtFinderFoot />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// The top bar, providing the framework for the header elements
export const ArtFinderHead = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    current,
    pos_xy,
    z_level,
    level,
    exp,
    exp_next_lvl,
    max_memory,
    num_memory,
    scanning,
    scan_timeleft,
    can_common,
    can_uncommon,
    can_rare,
    scan_common,
    scan_uncommon,
    scan_rare,
    paper_left,
    paper_max,
    score,
    scoretotal,
    username,
  } = data;

  return (
    <Box
      width="100%"
      height={AF_HeadSize}
      style={{
        border: "1px solid",
        borderColor: "#000",
        backgroundColor: "#000",
      }}>
      <Stack fill vertical>
        <Stack.Item grow shrink>
          <Flex>
            <Flex.Item basis="50%">
              <ArtUser />
            </Flex.Item>
            <Flex.Item basis="50%">
              <ArtLevel />
            </Flex.Item>
          </Flex>
        </Stack.Item>
        <Stack.Item grow shrink>
          <Flex>
            <Flex.Item basis="50%">
              <ArtPos />
            </Flex.Item>
            <Flex.Item basis="50%">
              <ArtSearch />
            </Flex.Item>
          </Flex>
        </Stack.Item>
        <Stack.Item grow shrink>
          <Flex>
            <Flex.Item basis="50%">
              <ArtMemory />
            </Flex.Item>
            <Flex.Item basis="50%">
              <ArtPaper />
            </Flex.Item>
          </Flex>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

/// The username and score. Includes this round's score and the total score.
/// Username is a button to login/logout. Includes a lederboard button.
export const ArtUser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    score,
    scoretotal,
    username,
    pos_xy,
    region,
    pos_error,
  } = data;

  return (
    <Stack fill vertical>
      <Stack.Item grow shrink>
        <Flex>
          <Flex.Item grow shrink>
            <ArtUsernameButton />
          </Flex.Item>
          <Flex.Item shrink>
            <Button
              icon="trophy"
              tooltip="Leaderboard"
              onClick={() => act("leaderboard")}
            />
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item grow shrink>
        <Stack fill vertical>
          <Stack.Item grow shrink>
            {pos_xy}
          </Stack.Item>
          <Stack.Item grow shrink>
            {region}
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

/// The username button. Includes the username and a button to change user.
export const ArtUsernameButton = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    username,
  } = data;

  return (
    <Button
      icon="user"
      content={username}
      onClick={() => act("change_user")}
    />
  );
};

/// The current level and experience. Includes the progress bar.
export const ArtLevel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    level,
    exp,
  } = data;
  const {
    exp_total,
    exp_total_max,
    exp_lvl,
    exp_lvl_max,
  } = exp;

  const lvl_read = "LVL: " + level;
  const exp_read = exp_total + " / " + exp_total_max;

  return (
    <Stack fill vertical>
      <Stack.Item grow shrink>
        {lvl_read}
      </Stack.Item>
      <Stack.Item grow shrink>
        <ProgressBar
          value={exp_lvl}
          minValue={0}
          maxValue={exp_lvl_max}
          ranges={{
            good: [-Infinity, Infinity],
          }}>
          {exp_read}
        </ProgressBar>
      </Stack.Item>
    </Stack>
  );
};

/// The search settings and the scan button.
/// The scan button turns into a progress bar when scanning.
/// The scan button is also disabled when scanning.
/// Includes 3 buttons to change the search settings.
/// The search settings are common, uncommon, and rare.
/// Higher search settings are unlocked at higher levels.
export const ArtSearch = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    scan_data,
  } = data;
  const {
    scanning,
    time_max,
    time_curr,
    can_common,
    can_uncommon,
    can_rare,
    scan_common,
    scan_uncommon,
    scan_rare,
    memory_full,
  } = scan_data;

  const scan_read = "SCAN: " + scan_timeleft + "s";
  const scan_bread = "SCAN: " + time_max + "s";
  const scan_disabled = scanning ? true : false;
  let button_state = null;
  if (scan_disabled) {
    button_state = (
      <ProgressBar
        value={time_curr}
        minValue={0}
        maxValue={time_max}
        ranges={{
          good: [-Infinity, Infinity],
        }}>
        {scan_read}
      </ProgressBar>)
  } else if (memory_full) {
    button_state = (
      <Box
        width="100%"
        height="100%"
        textAlign="center"
        style={{
          border: "1px solid",
          borderColor: "#000",
          backgroundColor: "#000",
        }}>
        Memory full!
      </Box>)
  } else {
      button_state = (
        <Button
          icon="search"
          content={scan_bread}
          onClick={() => act("start_scan")}
        />)
  }
  return (
    <Stack fill vertical>
      <Stack.Item grow shrink>
        {button_state}
      </Stack.Item>
      <Stack.Item grow shrink>
        <Flex>
          <Flex.Item shrink>
            <Button
              icon="search"
              disabled={!can_common}
              selected={scan_common}
              tooltip="Include/Exclude low-intensity signals."
              content="LOW"
              onClick={() => act("toggle_common")}
            />
          </Flex.Item>
          <Flex.Item shrink>
            <Button
              icon="search"
              disabled={!can_uncommon}
              selected={scan_uncommon}
              tooltip="Include/Exclude mid-intensity signals."
              content="MID"
              onClick={() => act("toggle_uncommon")}
            />
          </Flex.Item>
          <Flex.Item shrink>
            <Button
              icon="search"
              disabled={!can_rare}
              selected={scan_rare}
              tooltip="Include/Exclude high-intensity signals."
              content="HIGH"
              onClick={() => act("toggle_rare")}
            />
          </Flex.Item>
        </Flex>
      </Stack.Item>
    </Stack>
  );
};

/// The memory usage and the max memory.
/// Includes a button to clear the memory.
export const ArtMemory = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    memory_full,
    num_memory,
    max_memory,
  } = data;

  let mem_read = "MEM: " + num_memory + " / " + max_memory;
  if (memory_full) {
    mem_read = mem_read + " (full!)";

  return (
    <Flex>
      <Flex.Item grow>
        {mem_read}
      </Flex.Item>
      <Flex.Item shrink>
        <Button
          icon="trash"
          content="Purge?"
          onClick={() => act("clear")}
        />
      </Flex.Item>
    </Flex>
  );
};

/// The current paper and the max paper.
/// Includes a button to eject a sheet of paper.
export const ArtPaper = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    paper_left,
    paper_max,
  } = data;

  let paper_read = "PAPER: " + paper_left + " / " + paper_max;
  if (paper_left == 0) {
    paper_read = paper_read + " (empty!)";
  } else if (paper_left >= paper_max) {
    paper_read = paper_read + " (full!)";
  }

  return (
    <Flex>
      <Flex.Item grow>
        {paper_read}
      </Flex.Item>
      <Flex.Item shrink>
        <Button
          icon="eject"
          content="Eject?"
          onClick={() => act("eject")}
        />
      </Flex.Item>
    </Flex>
  );
};

/// The middle section that holds all the entries.
/// runs through the list of entries and creates an entry for each.
export const ArtFinderMid = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    memory_data,
  } = data;

  return (
    <Section fill scrollable>
      <Stack fill vertical>
        {memory_data.map((entry, i) => (
          <Stack.Item grow shrink>
            <Section>
              <ArtFinderEntry
                key={i}
                {memory_data[i]}
              />
            </Section>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

/// An entry for the artifact list.
/// Includes the name, coords (with error), and its discoverer (if any).
/// Includes a button to discard this entry from the scanner's memory.
/// Includes a button to update its coords.
/// Includes a button to enhance the scan resolution.
/// Is passed the entry's data from the butt end.
export const ArtFinderEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    art_name,
    x_read,
    y_read,
    z_disp,
    is_updating,
    update_timeleft,
    update_progress,
    time_since_update,
    can_enhance,
    enhancing,
    enhance_timeleft,
    enhance_progress,
    enhance_text,
    disco_text,
    rarity,
  } = props;
  const {
    paper_left,
  } = data;
  let raricon = "question";
  let rarcolor = "label";
  switch (rarity) {
    case "1":
      raricon = "circle";
      rarcolor = "#fff";
      break;
    case "2":
      raricon = "square";
      rarcolor = "#03f";
      break;
    case "3":
      raricon = "triangle";
      rarcolor = "#f0f";
      break;
    default:
      raricon = "question";
      break;

  return (
    <Stack fill vertical>
      <Stack.Item grow shrink>
        <Flex>
          <Flex.Item basis="50%">
            <Icon
              name={raricon}
              color={rarcolor}
            />
            {art_name}
          </Flex.Item>
          <Flex.Item grow>
            {disco_text}
          </Flex.Item>
          <Flex.Item shrink>
            <Button.Confirm
              icon="trash"
              content="X"
              color="bad"
              onClick={() => act("discard", { art_name })}
            />
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item grow shrink>
        <Flex>
          <Flex.Item basis="50%">
            <Stack fill>
              <Stack.Item grow shrink>
                {x_read}
              </Stack.Item>
              <Stack.Item grow shrink>
                {y_read}
              </Stack.Item>
            </Stack>
          </Flex.Item>
          <Flex.Item basis="50%">
            {is_updating ? (
              <ProgressBar
                value={update_progress}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [-Infinity, Infinity],
                }}>
                {update_timeleft}
              </ProgressBar>
            ) : (
              <Button
                icon="sync"
                content={time_since_update}
                onClick={() => act("update_coords", { art_name })}
              />
            )}
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item grow shrink>
        <Flex>
          <Flex.Item basis="50%">
            {z_disp}
          </Flex.Item>
          <Flex.Item grow>
            {enhancing ? (
              <ProgressBar
                value={enhance_progress}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [-Infinity, Infinity],
                }}>
                {enhance_timeleft}
              </ProgressBar>
            ) : (
              <Button
                icon="search-plus"
                disabled={!can_enhance}
                content={enhance_text}
                onClick={() => act("enhance", { art_name })}
              />
            )}
          </Flex.Item>
          <Flex.Item shrink>
            <Button
              icon="print"
              disabled={!!!paper_left}
              onClick={() => act("print", { art_name })}
            />
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item>
        <Box
          width="100%"
          height="1rem"
          color="label"
          textAlign="center"
        />
      </Stack.Item>
    </Stack>
  );
};




