import sys
import os

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: python3 analyze_results.py <PATH/TO/IMAGES/TXT> <PATH/TO/POINTS3D/TXT>')
        exit(0)

    images_txt_filename = sys.argv[1]
    if not os.path.exists(images_txt_filename):
        print(f'File not exits: {images_txt_filename}')
        exit(0)
    points3d_txt_filename = sys.argv[2]
    if not os.path.exists(points3d_txt_filename):
        print(f'File not exits: {points3d_txt_filename}')
        exit(0)

    with open(images_txt_filename, 'r') as images_file:
        with open(points3d_txt_filename, 'r') as points3d_file:
            for i in range(4):
                line = images_file.readline()
            line = images_file.readline()
            while line:
                words = line.split()
                image_name = words[-1]
                if image_name > 'images/Query_00000310.jpg' and image_name <= 'images/Query_00000389.jpg':
                    print(image_name)
                    line = images_file.readline()
                    data = line.split()
                    print(f'current image has {len(data) / 3} local features')
                    num_features_observed = 0
                    i = 0
                    while i < len(data):
                        point3d_id = data[i + 2]
                        if point3d_id != '-1':
                            # print(point3d_id)
                            num_features_observed += 1
                        i += 3
                    print(f'current image has {num_features_observed} local features observed')
                else:
                    line = images_file.readline()
                line = images_file.readline()