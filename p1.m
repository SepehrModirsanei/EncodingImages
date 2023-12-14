% Create a character mapset

MapSet = cell(2, 32);

% Define the characters and their corresponding binary values
characters = ['a':'z' ' ' ';' '?' '"!' ','];
binary_values = cellstr(num2str(dec2bin(0:31, 5)));

% Fill the MapSet with characters and their binary representations
for i = 1:numel(characters)
    MapSet{1, i} = characters(i);
    MapSet{2, i} = binary_values{i};
end

% Display the MapSet
% disp('MapSet:');
% disp(MapSet);

% 
input_text ='salam,azizam,asheghetam!!!!';
binary_text = text_to_binary2(input_text, MapSet);
% disp(binary_text);
image_path="/Users/sepehr/Desktop/University Of Tehran/Signal/CA3/LA.jpg";
img = imread(image_path);
gray_img=my_gray_function(img);
encoded_img=embed_text_in_grayscale_image(gray_img,binary_text);
are_same = check_grayscale_images(gray_img, encoded_img);
if(are_same)
    disp("true");
end
figure(4)
subplot(2,1,1)
imshow(gray_img)
subplot(2,1,2)
imshow(encoded_img)
decoded_text = decode_text_from_grayscale_image3(encoded_img, MapSet);
disp(decoded_text);
function encoded_image = embed_text_in_grayscale_image(img, binary_text)
    % Read the image
    [rows, cols] = size(img);

    if numel(binary_text) > rows * cols
        error('Binary text too large to be hidden in the image');
    end

    % Flatten the image matrix
    img_vector = img(:);

    % Embed the data in the least significant bit of each pixel
    for i = 1:numel(binary_text)
        bit_value = str2double(binary_text(i));
%         disp("bit value:");
%         disp(bit_value);
        img_vector(i) = bitset(img_vector(i), 1, bit_value);
    end

    % Reshape the modified image vector back to the original image dimensions
    img_modified = reshape(img_vector, rows, cols);

    % Return the encoded image
    encoded_image = img_modified;
end

function grayImage = my_gray_function(POINTS)
    grayImage = 0.299 * POINTS(:, :, 1) + 0.578 * POINTS(:, :, 2) + 0.114 * POINTS(:, :, 3);
end

function are_same = check_grayscale_images(img1, img2)
    % Check if the dimensions of the images are the same
    if ~isequal(size(img1), size(img2))
        are_same = false;
        return;
    end

    % Get the dimensions of the images
    [rows, cols] = size(img1);

    % Iterate through each pixel and compare the values
    for i = 1:rows
        for j = 1:cols
            if img1(i, j) ~= img2(i, j)
                are_same = false;
                return;
            end
        end
    end

    % If all pixels are the same, return true
    are_same = true;
end

function binary_text = text_to_binary2(input_text, MapSet)
    binary_text = cell(1, 5 * length(input_text));

    for i = 1:length(input_text)
        character = input_text(i);

        for j = 1:length(MapSet)
            if strcmp(MapSet{1, j}, character)
                bin_value = MapSet{2, j};
                for z = 1:length(bin_value)
                    binary_text{5 * (i - 1) + z} = bin_value(z);
                end
            end
        end
    end

    % Combine 5 consecutive bits into one 5-bit binary representation
%     binary_text = reshape(binary_text, 5, []).';
%     binary_text = cellfun(@(x) [x{:}], binary_text, 'UniformOutput', false);
end

function decoded_text = decode_text_from_grayscale_image3(encoded_img, MapSet)
    % Flatten the image matrix
    img_flat = encoded_img(:);

    % Initialize variables
    secret_binary = '';
    decoded_text = '';
    exit_code = '!!!';

    % Iterate through the flattened image vector
    for i = 1:length(img_flat)
        % Extract the least significant bit of each pixel and add it to the secret binary string
        secret_binary = strcat(secret_binary, num2str(bitget(img_flat(i), 1)));

        % Check if 5 bits are available for decoding
        if mod(length(secret_binary), 5) == 0
            % Convert the 5-bit binary string to a character
            binary_char = secret_binary(end-4:end);

            % Check for the exit code
            if length(decoded_text) >= 3 && strcmp(decoded_text(end-2:end), exit_code)
                break;
            end

            % Decode the character based on the MapSet
            for j = 1:size(MapSet, 2)
                if strcmp(MapSet{2, j}, binary_char)
                    decoded_text = strcat(decoded_text, MapSet{1, j});
                    break;
                end
            end

            % Reset the secret binary for the next 5 bits
            secret_binary = '';
        end
    end

    disp('Text successfully decoded from the image.');
end



