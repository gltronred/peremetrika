
import cv2
import numpy as np
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon

import json
from timeit import time
import copy

drag_pos = (-1, -1)
drag_points = []

def draw_polygon(img, poly, color):
    for i in range(len(poly)):
        i2 = (i + 1) % len(poly)
        cv2.line(img, poly[i], poly[i2], color, 1)

def to_int_tuple(arr):
    return (int(arr[0]), int(arr[1]))


def save_tracks(tracks, areas, frame, path):
    # save_to_file = json.dumps(tracks)
    tracks_direction_count = {}
    for t in tracks:
        start_idx = -1
        end_idx = -1
        for idx, a in enumerate(areas):
            p1 = Point(t[0][1][0], t[0][1][1])
            p2 = Point(t[-1][1][0], t[-1][1][1])
            polygon = Polygon(a)
            if polygon.contains(p1):
                start_idx = idx
            if polygon.contains(p2):
                end_idx = idx

        print(start_idx, end_idx)
        if start_idx >= 0 and end_idx >= 0 and start_idx != end_idx:
            p1 = to_int_tuple(t[0][1])
            p2 = to_int_tuple(t[-1][1])
            cv2.circle(frame, p1, 3, (255, 0, 0), -1)
            cv2.circle(frame, p2, 3, (0, 255, 0), -1)
            cv2.line(frame, p1, p2, (0, 0, 255), 1)
            key = (start_idx, end_idx)
            if key not in tracks_direction_count:
                tracks_direction_count[key] = 0
            tracks_direction_count[key] += 1

    max_frame_id = 0
    for t in tracks:
        for elem in t:
            max_frame_id = max(elem[0], max_frame_id)

    cv2.imshow("result", frame)
    cv2.waitKey()

    result = []
    for k, v in tracks_direction_count.items():
        src_idx = k[0] * 2 - 1
        dst_idx = k[1] * 2
        if src_idx < 0:
            src_idx += 8

        dic = {"src": src_idx,
               "dst": dst_idx,
               "count": v}
        result.append(dic)


    with open(path, 'w') as f:
        f.write(json.dumps(result))


def main():
    boxes = []

    def on_mouse(event, x, y, flags, params):
        global drag_pos
        if event == cv2.EVENT_LBUTTONDOWN:
            drag_points.append((x, y))
            if len(drag_points) == 4:
                boxes.append(copy.copy(drag_points))
                drag_points.clear()
        elif event == cv2.EVENT_MOUSEMOVE:
            drag_pos = (x, y)

    video_capture = cv2.VideoCapture("/Users/alex/Desktop/cross_rec_3.mp4")
    ret, first_frame = video_capture.read()
    frame = first_frame.copy()

    with open('directions_3.json', 'r') as f:
        directions = json.load(f)

    for v in directions.values():
        p1 = to_int_tuple(v[0][1])
        p2 = to_int_tuple(v[-1][1])
        cv2.circle(frame, p1, 3, (255, 0, 0), -1)
        cv2.circle(frame, p2, 3, (0, 255, 0), -1)
        cv2.line(frame, p1, p2, (0, 0, 255), 1)


    cv2.namedWindow('img')
    cv2.setMouseCallback('img', on_mouse, 0)

    orig_frame = frame
    while True:
        global drag_pos

        frame = orig_frame.copy()
        for b in boxes:
            draw_polygon(frame, b, (100, 255, 255))
        if len(drag_points) > 0:
            drags = drag_points.copy()
            drags.append(drag_pos)
            draw_polygon(frame, drags, (0, 255, 255))

        cv2.imshow("img", frame)
        key = cv2.waitKey(1)
        if key & 0xFF == ord('q'):
            break
        if key & 0xFF == ord('d'):
            if len(boxes) > 0:
                del boxes[-1]
        if key & 0xFF == ord('s'):
            save_tracks(directions.values(), boxes, first_frame, 'directions_processed_3.json')


if __name__ == '__main__':
    main()