import sys
import os
#import matplotlib.pyplot as plt
# import numpy as np

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

    imagename_3Dpoints_num_dict = {}

    with open(images_txt_filename, 'r') as images_file:
        with open(points3d_txt_filename, 'r') as points3d_file:
            for i in range(4):
                line = images_file.readline()
            line = images_file.readline()
            images_num = 390
            x = [i for i in range(images_num)]
            points2ds = [0]*images_num
            points3ds = [0]*images_num
            while line:
                words = line.split()
                image_name = words[-1]
                image_id = int(words[0])
                # if image_name > 'images/Query_00000310.jpg' and image_name <= 'images/Query_00000389.jpg':
                if 'Query' in image_name:
                    print(image_name)
                    line = images_file.readline()
                    data = line.split()
                    num_point2ds = len(data) / 3
                    print(f'current image has {num_point2ds} local features')
                    num_features_observed = 0
                    i = 0
                    while i < len(data):
                        point3d_id = data[i + 2]
                        if point3d_id != '-1':
                            # print(point3d_id)
                            num_features_observed += 1
                        i += 3
                    print(f'current image has {num_features_observed} local features observed')
                    points2ds[image_id - 1131] = num_point2ds
                    points3ds[image_id - 1131] = num_features_observed
                    imagename_3Dpoints_num_dict[image_name] = num_features_observed
                else:
                    line = images_file.readline()
                line = images_file.readline()

            #fig, ax = plt.subplots()
            #ax.plot(x, points2ds, label='number of points2d')
            #ax.plot(x, points3ds, label='number of points3d')
            #ax.legend()
            #plt.xlabel('query image id')
            #plt.show()
    
    with open('imagename_3Dpoints_num_dict.txt', 'w') as f:
        for key in imagename_3Dpoints_num_dict.keys():
            imagename = key.split('/')[-1]
            f.write(f'{imagename} {imagename_3Dpoints_num_dict[key]}\n')
