//
//  TypeDefsEnums.h
//  Instasite
//
//  Created by mike davis on 10/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

enum GitHubRepoTest {
  GitHubRepoExists, GitHubRepoDoesNotExist, GitHubResponsePending, GitHubRepoError
};
typedef enum GitHubRepoTest GitHubRepoTest;

enum GitHubPagesStatus {
  GitHubPagesNone, GitHubPagesInProgress, GitHubPagesBuilt, GitHubPagesError
};
typedef enum GitHubPagesStatus GitHubPagesStatus;

enum TemplateFieldType {
  FieldTXF, FieldTXV, FieldIMG
};
typedef enum TemplateFieldType TemplateFieldType;

enum FileType {
  FileTypeHtml      = 1 << 0,
  FileTypeJson      = 1 << 1,
  FileTypeJpeg      = 1 << 2,
  FileTypeTemplate  = 1 << 3,
  FileTypeOther     = 1 << 4
};
typedef enum FileType FileType;

enum ErrorCode {
  ErrorCodeNone = 0,
  ErrorCodeNotAuthorized = 101,
  ErrorCodeEntityNotFound = 102,
  ErrorCodeOperationIncomplete = 103,
  ErrorCodeWritingUserData = 201,
  ErrorCodeReadingUserData = 202,
  ErrorCodeWritingProjectData = 211,
  ErrorCodeReadingProjectData = 212,
  ErrorCodeUnknownError = 999
};
typedef enum ErrorCode ErrorCode;

typedef NSArray FileInfoArray;
typedef NSMutableArray FileInfoMutableArray;

typedef NSDictionary HtmlTemplateDictionary;
typedef NSMutableDictionary HtmlTemplateMutableDictionary;

typedef NSArray FileJsonRequestArray;
typedef NSMutableArray FileJsonRequestMutableArray;

typedef NSArray FileJsonResponseArray;
typedef NSMutableArray FileJsonResponseMutableArray;

typedef NSArray RepoJsonResponseArray;
typedef NSMutableArray RepoJsonResponseMutableArray;

typedef NSDictionary InputFieldDictionary;
typedef NSMutableDictionary InputFieldMutableDictionary;

typedef NSDictionary InputCategoryDictionary;
typedef NSMutableDictionary InputCategoryMutableDictionary;

typedef NSDictionary InputGroupDictionary;
typedef NSMutableDictionary InputGroupMutableDictionary;

typedef NSDictionary ImagesDictionary;
typedef NSMutableDictionary ImagesMutableDictionary;
