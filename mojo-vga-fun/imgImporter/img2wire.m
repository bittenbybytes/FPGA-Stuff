function wireImg = img2wire(filename)

	img = imread(filename);
	
	imgSmall = imresize(img, [180, 320]);
	
	wireImg = rgb2gray(imgSmall - mod(imgSmall,32));%
	
	fid = fopen('image.v', 'w');
	
	[height width] = size(wireImg)
	
	fprintf(fid, 'wire [15:0] width = %i;\n', width);
	fprintf(fid, 'wire [15:0] height = %i;\n', height);
	fprintf(fid, '\n');
	
	fprintf(fid, 'wire [2:0] img [%i : 0];\n', height*width-1);
	fprintf(fid, '\n');
	
	idx = 0;
	for row = 1:height;
		for col = 1:width;
			fprintf(fid, "assign img [%i] = 3\'h%i;\n", idx, uint8(wireImg(row,col)/32));
			idx = idx + 1;
		end;
	end
	fclose(fid);
return
