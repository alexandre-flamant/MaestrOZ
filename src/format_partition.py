import re

partition = """2D4 2D4 2D4 2D4 2D4 2D4 2D4 2D3"""


def format_partition(text: str):
    durations = []
    for duration in re.findall(r'[\d/]+[a-gA-GsS]', text):
        match list(duration):
            case [num, r'/', denom, _]:
                durations.append(float(num) / float(denom))
            case [seconds, _]:
                durations.append(float(seconds))
            case _:
                print(f'Error {list(duration)}')

    notes = re.findall(r'[a-gA-G#silence]+\d?', text)
    ref = ['c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#', 'a', 'a#', 'b']

    assert len(text.split()) == len(
        notes), f"Text seems to contain {len(text.split())} notes and notes contains {len(notes)} notes ! "
    assert len(text.split()) == len(
        durations), f"Text seems to contain {len(text.split())} notes and duration {len(durations)} durations ! "
    assert len(notes) == len(durations), f"There are {len(notes)} notes and {len(durations)} durations ! "

    partition = []
    for duration, note in zip(durations, notes):
        match list(note):
            case ['s', 'i', 'l', 'e', 'n', 'c', 'e']:
                if duration == 1.:
                    partition.append(f'silence')
                else:
                    partition.append(f'stretch(factor:{duration:.3f} [silence])')
            case [letter, octave]:
                if duration == 1.:
                    partition.append(f'{letter.lower()}{octave}')
                else:
                    partition.append(f'stretch(factor:{duration:.3f} [{letter.lower()}{octave}])')
            case [letter, '#', octave]:
                if duration == 1.:
                    partition.append(f'{letter.lower()}#{octave}')
                else:
                    if letter.lower() == 'b':
                        octave = int(octave) + 1
                        partition.append(f'stretch(factor:{duration:.3f} [c{octave}])')
                    else:
                        partition.append(f'stretch(factor:{duration:.3f} [{letter.lower()}#{octave}])')
            case [letter, 'b', octave]:
                if letter.lower() == 'c':
                    octave = int(octave) - 1
                letter = ref[ref.index(letter.lower()) - 1]
                if duration == 1.:
                    partition.append(f'{letter.lower()}{octave}')
                else:
                    partition.append(f'stretch(factor:{duration:.3f} [{letter.lower()}{octave}])')
            case _:
                print(f'Error {list(note)}')

    for i, j in zip(partition, text.split()):
        print(f'{j} -> {i}')

    strpartition = ''
    for i, item in enumerate(partition):
        if not (i % 5):
            strpartition += f'\n{item}'
        else:
            strpartition += f' {item}'

    strpartition = f'[{strpartition[1:]}]'

    print(strpartition)


format_partition(partition)
