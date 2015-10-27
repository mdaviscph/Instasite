//
//  TypeDefsEnums.h
//  Instasite
//
//  Created by mike davis on 10/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

enum FileType {
  IndexHtml, UserInputJson, Other, ImageJpeg, InstaSite
};
typedef enum FileType FileType;

typedef NSArray FileInfoArray;
typedef NSMutableArray FileInfoMutableArray;

typedef NSArray FileJsonRequestArray;
typedef NSMutableArray FileJsonRequestMutableArray;

typedef NSArray RepoJsonResponseArray;
typedef NSMutableArray RepoJsonResponseMutableArray;
