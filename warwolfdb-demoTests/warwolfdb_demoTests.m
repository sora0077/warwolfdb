//
//  warwolfdb_demoTests.m
//  warwolfdb-demoTests
//
//  Created by 林 達也 on 2014/03/10.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//


#import <Kiwi/Kiwi.h>
#import "WLFDatabase.h"
#import "WLFCursor.h"
#import "WLFTable.h"
#import "WLFEntity.h"
#import "WLFEntityIdentifier.h"
#import "WLFArray.h"
#import "WLFRepository.h"

#import "User.h"
#import "Book.h"

SPEC_BEGIN(demoTests)

describe(@"WLFEntity", ^{
    beforeEach(^{
        NSString *docsPath = (id)NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *dbPath   = [docsPath stringByAppendingPathComponent:@"testaaa.db"];

        NSURL *url = [NSURL fileURLWithPath:dbPath];

        [WLFDatabase connect:url];

        [WLFDatabase findSQL:@"PRAGMA foreign_keys" args:nil process:^id(WLFCursor *cursor) {
            if (cursor.next) {
                NSLog(@"%@", cursor.result);
            }
            return nil;
        }];
        [WLFDatabase executeSQL:@"PRAGMA foreign_keys = ON;"];

        [WLFDatabase findSQL:@"PRAGMA foreign_keys" process:^id(WLFCursor *cursor) {
            if (cursor.next) {
                NSLog(@"%@", cursor.result);
            }
            return nil;
        }];
        [WLFDatabase executeSQL:@"CREATE TABLE IF NOT EXISTS User (id TEXT PRIMARY KEY NOT NULL, name TEXT)"];
        [WLFDatabase executeSQL:@"CREATE TABLE IF NOT EXISTS Book (id TEXT PRIMARY KEY NOT NULL, name TEXT, auther_id TEXT, FOREIGN KEY(auther_id) REFERENCES User(id) ON DELETE SET NULL)"];
        [WLFDatabase executeSQL:@"CREATE TABLE IF NOT EXISTS User_has_Books (user_id TEXT NOT NULL, book_id TEXT NOT NULL, FOREIGN KEY(user_id) REFERENCES User(id) ON DELETE CASCADE, FOREIGN KEY(book_id) REFERENCES Book(id) ON DELETE CASCADE)"];
    });

    afterEach(^{
        [WLFDatabase executeSQL:@"DROP TABLE User_has_Books"];
        [WLFDatabase executeSQL:@"DROP TABLE Book"];
        [WLFDatabase executeSQL:@"DROP TABLE User"];
    });

    it(@"take it easy", ^{
        User *u1 = [User entity];
        [[u1.table.name should] equal:@"User".lowercaseString];

        [[u1.identifier shouldNot] equal:u1];
        [[u1 shouldNot] equal:u1.identifier];
    });

    it(@"book should has user reference, if user has book entities", ^{
        User *u1 = [User entity];

        Book *b1 = [Book entity];

        [[theValue(u1.auther__books.count) should] equal:theValue(0)];
        u1.auther__books = @[b1, [Book entity]];
        [[theValue(u1.auther__books.count) should] equal:theValue(2)];

        [[b1 should] equal:u1.auther__books[0]];
        [[u1 should] equal:b1.auther];

        b1.auther = nil;

        [[theValue(u1.auther__books.count) should] equal:theValue(1)];
        u1.auther__books = nil;
        [[theValue(u1.auther__books.count) should] equal:theValue(0)];

        [[b1.auther should] beNil];
    });

    it(@"user should has book references, if book has user entity", ^{
        User *u1 = [User entity];
        Book *b1 = [Book entity];

        [[theValue(u1.auther__books.count) should] equal:theValue(0)];
        b1.auther = u1;

        [[b1.auther should] beNonNil];
        [[theValue(u1.auther__books.count) should] equal:theValue(1)];

        [[b1 should] equal:u1.auther__books[0]];
        [[u1 should] equal:b1.auther];

        b1.auther = nil;
        [[theValue(u1.auther__books.count) should] equal:theValue(0)];
    });

    it(@"entity should not have retain cycle", ^{
        __weak User *user;

        Book *book = [Book entity];
        @autoreleasepool {
            User *u1 = [User entity];
            user = u1;
            Book *b1 = [Book entity];
            b1.auther = u1;
            book.auther = u1;
        }
        NSLog(@"%@", [WLFRepository entities]);
        [[user should] beNil];

    });
});

SPEC_END

