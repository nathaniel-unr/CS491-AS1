// Name: Nathaniel Daniel
// Email: nathanieldaniel@nevada.unr.edu

use std::collections::hash_map::Entry;
use std::collections::HashMap;
use std::collections::HashSet;
use std::collections::VecDeque;

const MAX_DEPTH: usize = 18;

struct SerMap<'a> {
    map: &'a HashMap<[u8; 16], State>,
}

impl serde::Serialize for SerMap<'_> {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        use serde::ser::SerializeMap;
        let mut map = serializer.serialize_map(Some(self.map.len()))?;
        for (k, v) in self.map.iter() {
            map.serialize_entry(
                itoa::Buffer::new().format(u128::from_le_bytes(*k)),
                &SerState { state: v },
            )?;
        }
        map.end()
    }
}

struct SerState<'a> {
    state: &'a State,
}

impl serde::Serialize for SerState<'_> {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        use serde::ser::SerializeStruct;

        let mut state = serializer.serialize_struct("State", 2)?;
        state.serialize_field("depth", &self.state.depth)?;
        state.serialize_field(
            "children",
            &SerStateChildren {
                children: &self.state.children,
            },
        )?;
        state.end()
    }
}

struct SerStateChildren<'a> {
    children: &'a [[u8; 16]],
}

impl serde::Serialize for SerStateChildren<'_> {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        use serde::ser::SerializeSeq;

        let mut seq = serializer.serialize_seq(Some(self.children.len()))?;
        for element in self.children.iter() {
            seq.serialize_element(itoa::Buffer::new().format(u128::from_le_bytes(*element)))?;
        }
        seq.end()
    }
}

struct State {
    depth: usize,
    children: Vec<[u8; 16]>,
}

fn main() {
    let mut queue = VecDeque::<([u8; 16], usize)>::with_capacity(1024);
    let mut map = HashMap::<[u8; 16], State>::with_capacity(1024);
    let mut seen = HashSet::<[u8; 16]>::with_capacity(1024);

    let win_state = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    queue.push_back((win_state, 0));
    seen.insert(win_state);

    while let Some((state, depth)) = queue.pop_front() {
        if depth == MAX_DEPTH {
            break;
        }

        let entry = match map.entry(state) {
            Entry::Vacant(entry) => entry.insert(State {
                children: Vec::new(),
                depth: depth + 1,
            }),
            Entry::Occupied(_entry) => {
                continue;
            }
        };
        let entry = &mut entry.children;

        let space_index = state.iter().position(|i| *i == 15).unwrap();

        if space_index > 3 {
            let mut new_state = state;
            new_state.swap(space_index, space_index - 4);

            entry.push(new_state);
            if seen.insert(new_state) {
                queue.push_back((new_state, depth + 1));
            }
        }

        if space_index < 12 {
            let mut new_state = state;
            new_state.swap(space_index, space_index + 4);

            entry.push(new_state);
            if seen.insert(new_state) {
                queue.push_back((new_state, depth + 1));
            }
        }

        if space_index % 4 != 0 {
            let mut new_state = state;
            new_state.swap(space_index, space_index - 1);

            entry.push(new_state);
            if seen.insert(new_state) {
                queue.push_back((new_state, depth + 1));
            }
        }

        if space_index != 3 && space_index != 7 && space_index != 11 && space_index != 15 {
            let mut new_state = state;
            new_state.swap(space_index, space_index + 1);

            entry.push(new_state);
            if seen.insert(new_state) {
                queue.push_back((new_state, depth + 1));
            }
        }
    }

    let file = std::fs::File::create(format!("{MAX_DEPTH}-ply.json")).expect("failed to open file");
    serde_json::to_writer(file, &SerMap { map: &map }).expect("failed to write json");
}
