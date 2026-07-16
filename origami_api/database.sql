-- ============================================================
--  OrigamiApp Database Setup
--  Chạy file này trên SQL Server (localhost:1433)
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'OrigamiApp')
    CREATE DATABASE OrigamiApp;
GO

USE OrigamiApp;
GO

-- ─── 1. Users ────────────────────────────────────────────────
IF OBJECT_ID('Users', 'U') IS NULL
CREATE TABLE Users (
    Id             INT IDENTITY(1,1) PRIMARY KEY,
    FullName       NVARCHAR(100)  NOT NULL,
    Email          NVARCHAR(150)  NOT NULL UNIQUE,
    PasswordHash   NVARCHAR(255)  NOT NULL,
    AvatarInitials NVARCHAR(5)   NOT NULL DEFAULT '',
    AvatarColor    NVARCHAR(10)  NOT NULL DEFAULT '#8B2FC9',
    Role           NVARCHAR(20)  NOT NULL DEFAULT 'USER',
    Nickname       NVARCHAR(50)  NULL,
    CreatedAt      DATETIME      NOT NULL DEFAULT GETDATE()
);
-- Thêm cột Role nếu bảng đã tồn tại
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'Role')
    ALTER TABLE Users ADD Role NVARCHAR(20) NOT NULL DEFAULT 'USER';
-- Thêm cột Nickname nếu bảng đã tồn tại
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Users') AND name = 'Nickname')
    ALTER TABLE Users ADD Nickname NVARCHAR(50) NULL;
GO

-- ─── 2. Categories ───────────────────────────────────────────
IF OBJECT_ID('Categories', 'U') IS NULL
CREATE TABLE Categories (
    Id      INT IDENTITY(1,1) PRIMARY KEY,
    Name    NVARCHAR(50)  NOT NULL,
    Emoji   NVARCHAR(5)   NOT NULL,
    BgColor NVARCHAR(10)  NOT NULL DEFAULT '#FFFFFF'
);

-- ─── 3. Tutorials ────────────────────────────────────────────
IF OBJECT_ID('Tutorials', 'U') IS NULL
CREATE TABLE Tutorials (
    Id               INT IDENTITY(1,1) PRIMARY KEY,
    Title            NVARCHAR(100)  NOT NULL,
    Difficulty       NVARCHAR(20)   NOT NULL,
    DifficultyColor  NVARCHAR(10)   NOT NULL,
    DifficultyBg     NVARCHAR(10)   NOT NULL,
    Rating           FLOAT          NOT NULL DEFAULT 0,
    ImageUrl         NVARCHAR(500)  NOT NULL DEFAULT '',
    LocalImageAsset  NVARCHAR(200)  NULL,
    StepCount        INT            NOT NULL DEFAULT 0,
    Duration         NVARCHAR(30)   NOT NULL DEFAULT '',
    Description      NVARCHAR(MAX)  NOT NULL DEFAULT '',
    CategoryId       INT            NULL REFERENCES Categories(Id),
    IsFeatured       BIT            NOT NULL DEFAULT 0,
    IsNew            BIT            NOT NULL DEFAULT 0,
    CreatedAt        DATETIME       NOT NULL DEFAULT GETDATE()
);

-- ─── 4. TutorialTags ─────────────────────────────────────────
IF OBJECT_ID('TutorialTags', 'U') IS NULL
CREATE TABLE TutorialTags (
    TutorialId INT         NOT NULL REFERENCES Tutorials(Id) ON DELETE CASCADE,
    Tag        NVARCHAR(50) NOT NULL,
    SortOrder  INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (TutorialId, Tag)
);

-- ─── 5. TutorialSteps ────────────────────────────────────────
IF OBJECT_ID('TutorialSteps', 'U') IS NULL
CREATE TABLE TutorialSteps (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    TutorialId  INT            NOT NULL REFERENCES Tutorials(Id) ON DELETE CASCADE,
    StepOrder   INT            NOT NULL,
    Title       NVARCHAR(100)  NOT NULL,
    Description NVARCHAR(MAX)  NOT NULL,
    ImageAsset  NVARCHAR(200)  NOT NULL
);

-- ─── 6. UserFavorites ────────────────────────────────────────
IF OBJECT_ID('UserFavorites', 'U') IS NULL
CREATE TABLE UserFavorites (
    UserId     INT  NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    TutorialId INT  NOT NULL REFERENCES Tutorials(Id) ON DELETE CASCADE,
    CreatedAt  DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (UserId, TutorialId)
);

-- ─── 7. UserOrigami ──────────────────────────────────────────
IF OBJECT_ID('UserOrigami', 'U') IS NULL
CREATE TABLE UserOrigami (
    UserId      INT  NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    TutorialId  INT  NOT NULL REFERENCES Tutorials(Id) ON DELETE CASCADE,
    CompletedAt DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (UserId, TutorialId)
);

-- ─── 8. UserFriends ──────────────────────────────────────────
IF OBJECT_ID('UserFriends', 'U') IS NULL
CREATE TABLE UserFriends (
    UserId    INT  NOT NULL REFERENCES Users(Id),
    FriendId  INT  NOT NULL REFERENCES Users(Id),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (UserId, FriendId)
);

-- ─── 10. FriendRequests ──────────────────────────────────────
IF OBJECT_ID('FriendRequests', 'U') IS NULL
CREATE TABLE FriendRequests (
    Id         INT IDENTITY(1,1) PRIMARY KEY,
    SenderId   INT NOT NULL REFERENCES Users(Id),
    ReceiverId INT NOT NULL REFERENCES Users(Id),
    Status     NVARCHAR(10) NOT NULL DEFAULT 'pending',
    CreatedAt  DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_FriendRequest UNIQUE (SenderId, ReceiverId)
);
-- Migration nếu bảng chưa tồn tại
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FriendRequests')
    EXEC('CREATE TABLE FriendRequests (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        SenderId INT NOT NULL REFERENCES Users(Id),
        ReceiverId INT NOT NULL REFERENCES Users(Id),
        Status NVARCHAR(10) NOT NULL DEFAULT ''pending'',
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT UQ_FriendRequest UNIQUE (SenderId, ReceiverId)
    )');

-- ─── 9. Notifications ────────────────────────────────────────
IF OBJECT_ID('Notifications', 'U') IS NULL
CREATE TABLE Notifications (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    UserId    INT            NOT NULL REFERENCES Users(Id) ON DELETE CASCADE,
    Title     NVARCHAR(200)  NOT NULL,
    Body      NVARCHAR(500)  NOT NULL,
    Icon      NVARCHAR(50)   NOT NULL DEFAULT 'notifications',
    IsRead    BIT            NOT NULL DEFAULT 0,
    CreatedAt DATETIME       NOT NULL DEFAULT GETDATE()
);

GO

-- ============================================================
--  SEED DATA
-- ============================================================

-- Categories
IF NOT EXISTS (SELECT 1 FROM Categories)
BEGIN
    INSERT INTO Categories (Name, Emoji, BgColor) VALUES
        (N'Động vật', N'🦢', '#EEF2FF'),
        (N'Hoa',       N'🌸', '#FCE7F3'),
        (N'Máy bay',   N'✈️', '#E0F2FE'),
        (N'Hộp',       N'📦', '#FEF3C7'),
        (N'Ngôi sao',  N'⭐', '#FFFBEB'),
        (N'Tim',       N'❤️', '#FFF1F2'),
        (N'Rồng',      N'🐉', '#ECFDF5'),
        (N'Thuyền',    N'⛵', '#EFF6FF');
END

-- Tutorials
IF NOT EXISTS (SELECT 1 FROM Tutorials)
BEGIN
    -- 1. Hoa sen (Featured, Category: Hoa = Id 2)
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, LocalImageAsset, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Hoa sen', N'Khó', '#EA580C', '#FFF7ED', 4.9,
            'https://picsum.photos/seed/lotus-flower/600/360',
            'assets/images/lotus.jpg', 16, N'20-30 phút',
            N'Hoa sen (荷花) là biểu tượng của sự thuần khiết và giác ngộ trong văn hóa châu Á. Mẫu origami này tái hiện vẻ đẹp tinh tế của hoa sen qua từng nếp gấp.',
            2, 1, 0);

    -- 2. Hạc giấy truyền thống (Featured, Category: Động vật = Id 1)
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, LocalImageAsset, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Hạc giấy truyền thống', N'Dễ', '#16A34A', '#DCFCE7', 4.8,
            'https://picsum.photos/seed/crane-paper/600/360',
            'assets/images/crane.jpg', 28, N'15-20 phút',
            N'Hạc giấy (折鶴, orizuru) là một trong những mẫu origami truyền thống và nổi tiếng nhất của Nhật Bản. Theo truyền thuyết, người gấp được 1000 con hạc giấy sẽ được thực hiện một điều ước.',
            1, 1, 0);

    -- 3. Rồng thần thoại (New, Category: Rồng = Id 7)
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, LocalImageAsset, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Rồng thần thoại', N'Rất khó', '#DC2626', '#FEE2E2', 5.0,
            'https://picsum.photos/seed/dragon-origami/600/360',
            NULL, 45, N'45-60 phút',
            N'Rồng thần thoại – tác phẩm origami phức tạp với nhiều chi tiết tinh xảo.',
            7, 0, 1);

    -- 4. Máy bay chiến đấu (New, Category: Máy bay = Id 3)
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, LocalImageAsset, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Máy bay chiến đấu', N'Dễ', '#16A34A', '#DCFCE7', 4.3,
            'https://picsum.photos/seed/fighter-plane/600/360',
            NULL, 12, N'10-15 phút',
            N'Mẫu máy bay chiến đấu cổ điển, dễ gấp và có thể bay xa.',
            3, 0, 1);

    -- 5. Bướm nhiều màu (New, Category: Động vật = Id 1)
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, LocalImageAsset, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Bướm nhiều màu', N'Trung bình', '#D97706', '#FEF3C7', 4.5,
            'https://picsum.photos/seed/butterfly-paper/600/360',
            NULL, 18, N'15-20 phút',
            N'Bướm giấy nhiều màu sắc, trang trí đẹp mắt.',
            1, 0, 1);
END

-- Tutorial Tags
IF NOT EXISTS (SELECT 1 FROM TutorialTags)
BEGIN
    -- Hoa sen (Id=1)
    INSERT INTO TutorialTags VALUES (1, N'Khó', 1), (1, N'Giấy', 2), (1, N'Hoa', 3), (1, N'Nghệ thuật', 4);
    -- Hạc giấy (Id=2)
    INSERT INTO TutorialTags VALUES (2, N'Dễ', 1), (2, N'Giấy', 2), (2, N'Động vật', 3), (2, N'Truyền thống', 4);
    -- Rồng (Id=3)
    INSERT INTO TutorialTags VALUES (3, N'Rất khó', 1), (3, N'Giấy', 2), (3, N'Động vật', 3), (3, N'Thần thoại', 4);
    -- Máy bay (Id=4)
    INSERT INTO TutorialTags VALUES (4, N'Dễ', 1), (4, N'Giấy', 2), (4, N'Máy bay', 3);
    -- Bướm (Id=5)
    INSERT INTO TutorialTags VALUES (5, N'Trung bình', 1), (5, N'Giấy', 2), (5, N'Động vật', 3);
END

-- Tutorial Steps: Hoa sen (TutorialId=1, 16 bước)
IF NOT EXISTS (SELECT 1 FROM TutorialSteps WHERE TutorialId = 1)
BEGIN
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (1, 1,  N'Chuẩn bị giấy vuông',    N'Bắt đầu với một tờ giấy hình vuông. Đặt giấy với mặt màu hướng xuống dưới.', 'assets/images/lotus_step/step-1.png'),
    (1, 2,  N'Gấp đôi theo chiều ngang', N'Gấp tờ giấy làm đôi từ trái sang phải tạo thành hình chữ nhật. Miết phẳng rồi mở ra.', 'assets/images/lotus_step/step-2.png'),
    (1, 3,  N'Gấp đôi theo chiều dọc',  N'Gấp tờ giấy làm đôi từ trên xuống dưới. Miết phẳng rồi mở ra để tạo nếp gấp.', 'assets/images/lotus_step/step-3.png'),
    (1, 4,  N'Gấp theo đường chéo',     N'Gấp tờ giấy theo đường chéo từ góc trái dưới lên góc phải trên. Miết phẳng rồi mở ra.', 'assets/images/lotus_step/step-4.png'),
    (1, 5,  N'Gấp chéo ngược',          N'Gấp theo đường chéo còn lại từ góc phải dưới lên góc trái trên. Mở ra để có đủ 4 nếp gấp.', 'assets/images/lotus_step/step-5.png'),
    (1, 6,  N'Thu gọn thành hình vuông', N'Sử dụng các nếp gấp sẵn có để thu gấp tờ giấy thành hình vuông nhỏ hơn với 4 lớp.', 'assets/images/lotus_step/step-6.png'),
    (1, 7,  N'Gấp các góc vào tâm',     N'Gấp từng góc của hình vuông vào điểm trung tâm. Làm đều cả 4 góc.', 'assets/images/lotus_step/step-7.png'),
    (1, 8,  N'Lật và gấp mặt sau',      N'Lật hình qua mặt sau rồi gấp 4 góc vào tâm như bước trước.', 'assets/images/lotus_step/step-8.png'),
    (1, 9,  N'Gấp tiếp các góc',        N'Tiếp tục gấp 4 góc vào tâm một lần nữa để tạo hình nhỏ hơn.', 'assets/images/lotus_step/step-9.png'),
    (1, 10, N'Lật mặt và ấn tâm',       N'Lật hình lại và nhẹ nhàng ấn vào tâm để các cánh bắt đầu nở ra.', 'assets/images/lotus_step/step-10.png'),
    (1, 11, N'Mở cánh ngoài',           N'Kéo nhẹ 4 cánh ở tầng ngoài cùng ra để tạo hình cánh hoa đầu tiên.', 'assets/images/lotus_step/step-11.png'),
    (1, 12, N'Mở cánh giữa',            N'Kéo các cánh ở tầng giữa ra, uốn nhẹ để chúng nằm giữa các cánh ngoài.', 'assets/images/lotus_step/step-12.png'),
    (1, 13, N'Mở cánh trong',           N'Nhẹ nhàng kéo các cánh ở tầng trong cùng ra. Đây là phần đòi hỏi sự tỉ mỉ nhất.', 'assets/images/lotus_step/step-13.png'),
    (1, 14, N'Định hình cánh hoa',      N'Uốn cong nhẹ các cánh hoa ra phía ngoài để tạo dáng tự nhiên cho hoa sen.', 'assets/images/lotus_step/step-14.png'),
    (1, 15, N'Hoàn thiện hình dạng',    N'Điều chỉnh tất cả các cánh hoa để đạt được sự cân đối và thẩm mỹ.', 'assets/images/lotus_step/step-15.png'),
    (1, 16, N'Hoàn thành hoa sen',      N'Hoa sen origami của bạn đã hoàn thành! Nhẹ nhàng điều chỉnh các cánh để tạo hình dáng đẹp nhất.', 'assets/images/lotus_step/step-16.png');
END

-- Tutorial Steps: Hạc giấy truyền thống (TutorialId=2, 28 bước)
IF NOT EXISTS (SELECT 1 FROM TutorialSteps WHERE TutorialId = 2)
BEGIN
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (2, 1,  N'Chuẩn bị giấy vuông',         N'Bắt đầu với một tờ giấy hình vuông. Đặt giấy với mặt màu hướng xuống dưới trên mặt phẳng.', 'assets/images/crane_step/step-1.png'),
    (2, 2,  N'Gấp chéo lần 1',              N'Gấp tờ giấy theo đường chéo từ góc dưới bên trái lên góc trên bên phải. Miết phẳng đường gấp rồi mở ra.', 'assets/images/crane_step/step-2.png'),
    (2, 3,  N'Gấp chéo lần 2',              N'Gấp theo đường chéo còn lại từ góc dưới bên phải lên góc trên bên trái. Miết phẳng và mở ra.', 'assets/images/crane_step/step-3.png'),
    (2, 4,  N'Gấp đôi theo chiều ngang',    N'Lật mặt giấy lại. Gấp tờ giấy làm đôi từ trái sang phải tạo hình chữ nhật. Miết phẳng rồi mở ra.', 'assets/images/crane_step/step-4.png'),
    (2, 5,  N'Gấp đôi theo chiều dọc',      N'Gấp tờ giấy làm đôi từ trên xuống dưới. Miết phẳng rồi mở ra. Lúc này có đủ 4 đường nếp gấp cơ bản.', 'assets/images/crane_step/step-5.png'),
    (2, 6,  N'Thu gọn thành đế sơ bộ',      N'Sử dụng các nếp gấp có sẵn, đẩy hai cạnh bên vào trong đồng thời để thu gọn tờ giấy thành hình vuông nhỏ hơn với 4 lớp.', 'assets/images/crane_step/step-6.png'),
    (2, 7,  N'Gấp cạnh trái vào giữa',      N'Xoay hình sao cho phần mở hướng xuống dưới. Gấp cạnh bên trái của lớp trên vào đường thẳng giữa.', 'assets/images/crane_step/step-7.png'),
    (2, 8,  N'Gấp cạnh phải vào giữa',      N'Gấp cạnh bên phải của lớp trên vào đường thẳng giữa. Hình có dạng con diều.', 'assets/images/crane_step/step-8.png'),
    (2, 9,  N'Gấp góc trên xuống',          N'Gấp góc trên (tam giác nhỏ) xuống dưới, vượt qua đường ngang nơi hai cạnh vừa gấp gặp nhau.', 'assets/images/crane_step/step-9.png'),
    (2, 10, N'Mở ra để lộ nếp gấp',         N'Mở tất cả các nếp gấp vừa thực hiện để trở về hình vuông ban đầu, nhưng giữ lại tất cả các đường nếp.', 'assets/images/crane_step/step-10.png'),
    (2, 11, N'Gấp cánh trước – petal fold', N'Nâng góc dưới của lớp trên lên trên, dùng các nếp có sẵn để ép hai cạnh bên vào trong tạo hình thoi (petal fold).', 'assets/images/crane_step/step-11.png'),
    (2, 12, N'Hoàn thiện cánh trước',       N'Miết phẳng cẩn thận để hình thoi phẳng hoàn toàn. Đường trung tâm phải thẳng.', 'assets/images/crane_step/step-12.png'),
    (2, 13, N'Lật hình',                    N'Lật toàn bộ hình qua mặt sau, giữ cẩn thận để không làm bung các nếp gấp.', 'assets/images/crane_step/step-13.png'),
    (2, 14, N'Gấp cạnh vào giữa – mặt sau', N'Lặp lại bước 7-8 trên mặt này: gấp cạnh trái và phải của lớp trên vào đường giữa.', 'assets/images/crane_step/step-14.png'),
    (2, 15, N'Gấp cánh sau – petal fold',   N'Lặp lại petal fold cho mặt sau: nâng góc dưới lên, ép hai bên vào trong tạo hình thoi.', 'assets/images/crane_step/step-15.png'),
    (2, 16, N'Gấp vạt trái lên – mặt trước', N'Trên mặt trước, gấp vạt phía dưới bên trái lên trên theo đường giữa, tạo hình dài và hẹp hơn.', 'assets/images/crane_step/step-16.png'),
    (2, 17, N'Gấp vạt phải lên – mặt trước', N'Gấp vạt phía dưới bên phải lên trên tương tự. Hình giờ trông như chiếc lá dài.', 'assets/images/crane_step/step-17.png'),
    (2, 18, N'Lật hình',                    N'Lật hình qua mặt sau một lần nữa để xử lý phần còn lại.', 'assets/images/crane_step/step-18.png'),
    (2, 19, N'Gấp vạt lên – mặt sau',       N'Lặp lại bước 16-17 trên mặt sau: gấp hai vạt dưới lên theo đường giữa.', 'assets/images/crane_step/step-19.png'),
    (2, 20, N'Phân chia cánh và đuôi',       N'Tách hai phần dài ở phía dưới ra, một bên sẽ là đầu và cổ, bên còn lại là đuôi.', 'assets/images/crane_step/step-20.png'),
    (2, 21, N'Gấp ngược tạo cổ hạc',        N'Thực hiện gấp ngược (reverse fold) cho một trong hai phần dài: ấn vào trong dọc theo đường giữa để tạo cổ hạc vươn lên.', 'assets/images/crane_step/step-21.png'),
    (2, 22, N'Gấp ngược tạo đuôi hạc',      N'Thực hiện gấp ngược tương tự cho phần còn lại để tạo đuôi hạc chỉ lên trên.', 'assets/images/crane_step/step-22.png'),
    (2, 23, N'Tạo đầu hạc',                 N'Ở phần cổ, thực hiện gấp ngược nhỏ (inside reverse fold) ở đầu mút để tạo mỏ hạc cúi xuống.', 'assets/images/crane_step/step-23.png'),
    (2, 24, N'Kéo cánh ra',                 N'Nhẹ nhàng kéo hai cánh hạc sang hai bên. Giữ phần thân bằng tay còn lại và kéo đều cả hai phía.', 'assets/images/crane_step/step-24.png'),
    (2, 25, N'Phồng thân hạc',              N'Nhẹ nhàng thổi vào lỗ nhỏ ở phần đuôi dưới hoặc ấn nhẹ hai bên hông để thân hạc phồng tròn ra.', 'assets/images/crane_step/step-25.png'),
    (2, 26, N'Điều chỉnh cánh',             N'Tiếp tục kéo và điều chỉnh hai cánh để đạt kích thước và góc mong muốn. Cánh nên nằm ngang.', 'assets/images/crane_step/step-26.png'),
    (2, 27, N'Uốn cổ và cánh',              N'Uốn cong nhẹ cổ hạc và đầu mút cánh để tạo dáng tự nhiên, uyển chuyển hơn.', 'assets/images/crane_step/step-27.png'),
    (2, 28, N'Hoàn thành hạc giấy',         N'Hạc giấy origami của bạn đã hoàn thành! Nhẹ nhàng tinh chỉnh cổ, đầu và cánh để đạt hình dáng đẹp nhất.', 'assets/images/crane_step/step-28.png');
END

-- ============================================================
--  BỔ SUNG BƯỚC CHO CÁC MẪU CŨ CÒN THIẾU
--  (Rồng thần thoại, Máy bay chiến đấu, Bướm nhiều màu được seed
--   với StepCount > 0 nhưng chưa có bước nào, khiến màn hình hướng
--   dẫn nhảy thẳng sang màn hoàn thành. Cập nhật StepCount cho khớp.)
-- ============================================================

DECLARE @tid INT;

-- Rồng thần thoại
SET @tid = (SELECT Id FROM Tutorials WHERE Title = N'Rồng thần thoại');
IF @tid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM TutorialSteps WHERE TutorialId = @tid)
BEGIN
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@tid, 1, N'Chuẩn bị giấy vuông',  N'Dùng tờ giấy vuông 15cm, mặt màu úp xuống. Giấy càng mỏng càng dễ gấp các chi tiết nhỏ của rồng.', 'assets/images/crane_step/step-1.png'),
    (@tid, 2, N'Tạo nếp chéo',         N'Gấp đôi theo cả hai đường chéo, miết phẳng rồi mở ra. Hai nếp này định vị thân và cánh rồng.', 'assets/images/crane_step/step-2.png'),
    (@tid, 3, N'Tạo nếp ngang dọc',    N'Lật giấy, gấp đôi theo chiều ngang rồi chiều dọc. Mở ra để có đủ 4 nếp gấp cơ bản.', 'assets/images/crane_step/step-3.png'),
    (@tid, 4, N'Thu gọn thành đế',     N'Dựa vào các nếp có sẵn, đẩy hai cạnh bên vào trong để thu tờ giấy thành đế vuông 4 lớp.', 'assets/images/crane_step/step-4.png'),
    (@tid, 5, N'Tạo hình đầu và cánh', N'Gấp ngược phần nhọn phía trên tạo đầu rồng, kéo hai lớp bên ra làm cánh rồi uốn cong đuôi.', 'assets/images/crane_step/step-5.png');
    UPDATE Tutorials SET StepCount = 5 WHERE Id = @tid;
END

-- Máy bay chiến đấu
SET @tid = (SELECT Id FROM Tutorials WHERE Title = N'Máy bay chiến đấu');
IF @tid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM TutorialSteps WHERE TutorialId = @tid)
BEGIN
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@tid, 1, N'Chuẩn bị giấy',        N'Dùng tờ giấy A4. Đặt giấy nằm dọc trên mặt phẳng, mặt màu úp xuống.', 'assets/images/crane_step/step-1.png'),
    (@tid, 2, N'Gấp đôi theo chiều dọc', N'Gấp đôi tờ giấy theo chiều dọc rồi mở ra. Nếp giữa này là trục đối xứng của máy bay.', 'assets/images/crane_step/step-2.png'),
    (@tid, 3, N'Gấp hai góc trên vào', N'Gấp hai góc trên vào đường giữa để tạo mũi nhọn hình tam giác.', 'assets/images/crane_step/step-3.png'),
    (@tid, 4, N'Gấp mũi lần hai',      N'Gấp tiếp hai cạnh xiên vào đường giữa. Mũi máy bay hẹp và nhọn hơn, phần đầu nặng giúp bay xa.', 'assets/images/crane_step/step-4.png'),
    (@tid, 5, N'Gấp cánh',             N'Gấp đôi máy bay vào trong, sau đó gấp hai cánh xuống song song với thân. Chỉnh cánh cân đối là xong.', 'assets/images/crane_step/step-5.png');
    UPDATE Tutorials SET StepCount = 5 WHERE Id = @tid;
END

-- Bướm nhiều màu
SET @tid = (SELECT Id FROM Tutorials WHERE Title = N'Bướm nhiều màu');
IF @tid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM TutorialSteps WHERE TutorialId = @tid)
BEGIN
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@tid, 1, N'Chuẩn bị giấy vuông',  N'Dùng giấy vuông hai mặt màu khác nhau để cánh bướm nổi bật hơn.', 'assets/images/crane_step/step-1.png'),
    (@tid, 2, N'Gấp chéo hai lần',     N'Gấp theo hai đường chéo, miết phẳng rồi mở ra sau mỗi lần gấp.', 'assets/images/crane_step/step-2.png'),
    (@tid, 3, N'Gấp ngang và dọc',     N'Lật giấy rồi gấp đôi theo chiều ngang và chiều dọc. Mở ra để có 4 nếp gấp.', 'assets/images/crane_step/step-3.png'),
    (@tid, 4, N'Thu thành tam giác',   N'Ấn nhẹ vào tâm và đẩy hai cạnh vào trong để thu giấy thành tam giác kép.', 'assets/images/crane_step/step-4.png'),
    (@tid, 5, N'Tạo cánh bướm',        N'Gấp hai góc dưới lên trên tạo cánh trên, gấp nhẹ thân xuống rồi banh cánh ra hai bên.', 'assets/images/crane_step/step-5.png');
    UPDATE Tutorials SET StepCount = 5 WHERE Id = @tid;
END
GO

-- ============================================================
--  MẪU BỔ SUNG — 2 mẫu cho mỗi thể loại, mỗi mẫu 5 bước
--  Mỗi khối tự kiểm tra theo Title nên chạy lại file này an toàn.
--  CategoryId tra theo tên để không phụ thuộc giá trị IDENTITY.
-- ============================================================

DECLARE @id INT;

-- ─── Động vật ────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Cá chép')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Cá chép', N'Dễ', '#16A34A', '#DCFCE7', 4.6,
            'https://picsum.photos/seed/koi-fish/600/360', 5, N'10-15 phút',
            N'Cá chép (鯉, koi) tượng trưng cho sự kiên trì và may mắn trong văn hoá Nhật Bản. Mẫu gấp đơn giản, phù hợp cho người mới bắt đầu.',
            (SELECT Id FROM Categories WHERE Name = N'Động vật'), 0, 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Dễ', 1), (@id, N'Giấy', 2), (@id, N'Động vật', 3);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông 15cm, mặt màu úp xuống. Nên chọn giấy màu cam hoặc đỏ cho giống cá chép.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Gấp chéo tạo tam giác', N'Gấp đôi theo đường chéo tạo thành tam giác. Miết phẳng nếp gấp.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Gấp hai góc lên',      N'Gấp hai góc đáy của tam giác lên đỉnh, tạo thành hình vuông nhỏ.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Tạo thân cá',          N'Gấp đôi hình theo chiều dọc rồi mở nhẹ ra để thân cá phồng lên.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Tạo đuôi và hoàn thiện', N'Gấp ngược phần nhọn phía sau tạo đuôi cá, vẽ thêm mắt là hoàn thành.', 'assets/images/crane_step/step-5.png');
END

IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Thỏ con')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Thỏ con', N'Trung bình', '#D97706', '#FEF3C7', 4.4,
            'https://picsum.photos/seed/paper-rabbit/600/360', 5, N'15-20 phút',
            N'Chú thỏ giấy với đôi tai dài đáng yêu. Mẫu này giúp bạn làm quen với kỹ thuật gấp ngược (reverse fold) để tạo tai.',
            (SELECT Id FROM Categories WHERE Name = N'Động vật'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Trung bình', 1), (@id, N'Giấy', 2), (@id, N'Động vật', 3);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông 15cm, mặt màu úp xuống trên mặt phẳng.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Gấp đôi theo chéo',   N'Gấp đôi theo đường chéo rồi mở ra để lấy nếp giữa làm trục đối xứng.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Gấp hai cạnh vào giữa', N'Gấp hai cạnh bên vào đường giữa tạo hình con diều thon dài.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Tạo tai thỏ',         N'Gấp đôi hình lại, sau đó gấp ngược phần nhọn lên trên tạo hai tai thỏ dài.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Tạo đuôi và hoàn thiện', N'Gấp góc phía sau vào trong tạo đuôi tròn, banh nhẹ tai và chỉnh dáng ngồi cho thỏ.', 'assets/images/crane_step/step-5.png');
END

-- ─── Hoa ─────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Hoa tulip')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Hoa tulip', N'Dễ', '#16A34A', '#DCFCE7', 4.7,
            'https://picsum.photos/seed/tulip-origami/600/360', 5, N'10-15 phút',
            N'Hoa tulip origami với dáng búp thanh lịch. Chỉ vài nếp gấp cơ bản là bạn đã có một bông hoa để trang trí.',
            (SELECT Id FROM Categories WHERE Name = N'Hoa'), 1, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Dễ', 1), (@id, N'Giấy', 2), (@id, N'Hoa', 3);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông màu hồng hoặc vàng, mặt màu úp xuống.', 'assets/images/lotus_step/step-1.png'),
    (@id, 2, N'Gấp chéo hai lần',    N'Gấp đôi theo cả hai đường chéo, miết phẳng rồi mở ra sau mỗi lần.', 'assets/images/lotus_step/step-2.png'),
    (@id, 3, N'Thu thành tam giác',  N'Ấn vào tâm, đẩy hai cạnh vào trong để thu giấy thành tam giác kép.', 'assets/images/lotus_step/step-3.png'),
    (@id, 4, N'Gấp cánh hoa',        N'Gấp hai góc đáy lên đỉnh ở cả hai mặt, tạo thành hình thoi.', 'assets/images/lotus_step/step-4.png'),
    (@id, 5, N'Thổi phồng búp hoa',  N'Gấp hai cánh bên lồng vào nhau, thổi nhẹ vào lỗ dưới đáy cho búp hoa phồng lên.', 'assets/images/lotus_step/step-5.png');
END

IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Hoa hồng')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Hoa hồng', N'Khó', '#EA580C', '#FFF7ED', 4.8,
            'https://picsum.photos/seed/rose-origami/600/360', 5, N'25-35 phút',
            N'Hoa hồng origami theo phong cách Kawasaki, đòi hỏi sự tỉ mỉ khi xoắn các lớp cánh. Thành phẩm rất xứng đáng với công sức bỏ ra.',
            (SELECT Id FROM Categories WHERE Name = N'Hoa'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Khó', 1), (@id, N'Giấy', 2), (@id, N'Hoa', 3), (@id, N'Nghệ thuật', 4);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông màu đỏ 15cm. Giấy mỏng sẽ dễ xoắn cánh hơn.', 'assets/images/lotus_step/step-1.png'),
    (@id, 2, N'Chia lưới 4x4',       N'Gấp đôi theo chiều ngang và dọc nhiều lần để chia tờ giấy thành lưới ô vuông đều.', 'assets/images/lotus_step/step-2.png'),
    (@id, 3, N'Gấp các góc vào tâm', N'Gấp cả 4 góc vào điểm trung tâm, miết phẳng để tạo hình vuông nhỏ hơn.', 'assets/images/lotus_step/step-3.png'),
    (@id, 4, N'Xoắn các lớp cánh',   N'Xoay nhẹ các lớp theo cùng một chiều để các cánh hoa chồng lên nhau. Đây là bước khó nhất, hãy làm từ từ.', 'assets/images/lotus_step/step-4.png'),
    (@id, 5, N'Uốn cánh hoàn thiện', N'Dùng đầu bút uốn cong mép từng cánh ra ngoài để bông hồng trông tự nhiên.', 'assets/images/lotus_step/step-5.png');
END

-- ─── Máy bay ─────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Phi cơ lượn')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Phi cơ lượn', N'Dễ', '#16A34A', '#DCFCE7', 4.2,
            'https://picsum.photos/seed/glider-plane/600/360', 5, N'5-10 phút',
            N'Máy bay giấy cánh rộng, bay chậm và lượn êm. Mẫu lý tưởng để thả trong nhà hoặc sân trường.',
            (SELECT Id FROM Categories WHERE Name = N'Máy bay'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Dễ', 1), (@id, N'Giấy', 2), (@id, N'Máy bay', 3);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy A4',    N'Đặt tờ giấy A4 nằm dọc trên mặt phẳng.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Tạo nếp giữa',        N'Gấp đôi theo chiều dọc rồi mở ra để lấy trục đối xứng.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Gấp hai góc trên',    N'Gấp hai góc trên vào đường giữa tạo mũi tam giác.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Gấp mũi cùn',         N'Gấp phần mũi nhọn xuống dưới tạo mũi cùn — đây là điểm giúp máy bay lượn thay vì lao nhanh.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Gấp cánh rộng',       N'Gấp đôi thân, sau đó gấp hai cánh bản rộng xuống. Bẻ nhẹ mép cánh sau lên để máy bay lượn lâu hơn.', 'assets/images/crane_step/step-5.png');
END

IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Tên lửa giấy')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Tên lửa giấy', N'Trung bình', '#D97706', '#FEF3C7', 4.4,
            'https://picsum.photos/seed/paper-rocket/600/360', 5, N'10-15 phút',
            N'Tên lửa giấy với mũi nhọn và cánh đuôi, bay rất nhanh và thẳng. Hãy thả ở nơi rộng rãi.',
            (SELECT Id FROM Categories WHERE Name = N'Máy bay'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Trung bình', 1), (@id, N'Giấy', 2), (@id, N'Máy bay', 3);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy A4',    N'Đặt tờ giấy A4 nằm dọc, mặt màu úp xuống.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Tạo nếp giữa',        N'Gấp đôi theo chiều dọc rồi mở ra.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Gấp mũi nhọn',        N'Gấp hai góc trên vào giữa, rồi gấp tiếp hai cạnh xiên vào giữa lần nữa để mũi thật nhọn.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Gấp thân hẹp',        N'Gấp đôi theo trục giữa. Thân tên lửa lúc này dài và hẹp, phần đầu nặng.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Tạo cánh đuôi',       N'Gấp hai cánh nhỏ sát thân, dựng đứng mép cánh phía đuôi để giữ tên lửa bay thẳng.', 'assets/images/crane_step/step-5.png');
END

-- ─── Hộp ─────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Hộp vuông cơ bản')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Hộp vuông cơ bản', N'Dễ', '#16A34A', '#DCFCE7', 4.5,
            'https://picsum.photos/seed/square-box/600/360', 5, N'10-15 phút',
            N'Hộp giấy masu truyền thống của Nhật Bản. Gấp thêm một chiếc lớn hơn một chút là bạn có luôn nắp đậy.',
            (SELECT Id FROM Categories WHERE Name = N'Hộp'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Dễ', 1), (@id, N'Giấy', 2), (@id, N'Hộp', 3), (@id, N'Truyền thống', 4);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông dày một chút để hộp đứng vững.', 'assets/images/lotus_step/step-1.png'),
    (@id, 2, N'Gấp chéo hai lần',    N'Gấp đôi theo hai đường chéo, miết phẳng rồi mở ra để xác định tâm.', 'assets/images/lotus_step/step-2.png'),
    (@id, 3, N'Gấp 4 góc vào tâm',   N'Gấp cả 4 góc vào điểm trung tâm, tạo thành hình vuông nhỏ hơn.', 'assets/images/lotus_step/step-3.png'),
    (@id, 4, N'Gấp cạnh vào giữa',   N'Gấp hai cạnh đối diện vào đường giữa rồi mở ra. Lặp lại với hai cạnh còn lại để tạo lưới nếp.', 'assets/images/lotus_step/step-4.png'),
    (@id, 5, N'Dựng thành hộp',      N'Dựng bốn cạnh lên theo nếp có sẵn, gấp hai góc còn lại vào trong lòng hộp và miết đáy cho phẳng.', 'assets/images/lotus_step/step-5.png');
END

IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Hộp trái tim')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Hộp trái tim', N'Trung bình', '#D97706', '#FEF3C7', 4.7,
            'https://picsum.photos/seed/heart-box/600/360', 5, N'20-25 phút',
            N'Chiếc hộp nhỏ có nắp hình trái tim, rất hợp để đựng quà tặng nhỏ hoặc lời nhắn.',
            (SELECT Id FROM Categories WHERE Name = N'Hộp'), 0, 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Trung bình', 1), (@id, N'Giấy', 2), (@id, N'Hộp', 3), (@id, N'Quà tặng', 4);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông màu hồng hoặc đỏ, mặt màu úp xuống.', 'assets/images/lotus_step/step-1.png'),
    (@id, 2, N'Chia lưới nếp gấp',   N'Gấp đôi theo chiều ngang và dọc, mở ra để chia tờ giấy thành 4 ô vuông bằng nhau.', 'assets/images/lotus_step/step-2.png'),
    (@id, 3, N'Gấp đáy hộp',         N'Gấp 4 góc vào tâm rồi gấp các cạnh vào giữa để định hình phần đáy vuông.', 'assets/images/lotus_step/step-3.png'),
    (@id, 4, N'Dựng thành hộp',      N'Dựng bốn cạnh lên, gài các góc vào nhau để hộp giữ được form.', 'assets/images/lotus_step/step-4.png'),
    (@id, 5, N'Gấp nắp trái tim',    N'Với tờ giấy thứ hai, gấp trái tim rồi đặt lên làm nắp. Chỉnh cho nắp vừa khít miệng hộp.', 'assets/images/lotus_step/step-5.png');
END

-- ─── Ngôi sao ────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Ngôi sao 5 cánh')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Ngôi sao 5 cánh', N'Trung bình', '#D97706', '#FEF3C7', 4.6,
            'https://picsum.photos/seed/five-star/600/360', 5, N'15-20 phút',
            N'Ngôi sao 5 cánh cân đối, thường dùng để trang trí cây thông hoặc làm đồ treo. Điểm mấu chốt là chia đều góc ở bước đầu.',
            (SELECT Id FROM Categories WHERE Name = N'Ngôi sao'), 1, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Trung bình', 1), (@id, N'Giấy', 2), (@id, N'Ngôi sao', 3), (@id, N'Trang trí', 4);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông màu vàng hoặc bạc để ngôi sao nổi bật.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Gấp đôi tờ giấy',     N'Gấp đôi tờ giấy lại thành hình chữ nhật, miết phẳng nếp gấp.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Chia đều 5 phần',     N'Gấp lần lượt để chia góc thành 5 phần bằng nhau. Bước này quyết định ngôi sao có cân đối hay không.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Gấp gọn hình nêm',    N'Gấp gọn các lớp lại thành hình nêm hẹp, các mép chồng khít lên nhau.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Cắt và mở sao',       N'Cắt một đường chéo ở đầu nêm rồi mở ra. Miết phẳng các cánh để hoàn thiện ngôi sao.', 'assets/images/crane_step/step-5.png');
END

IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Phi tiêu ninja')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Phi tiêu ninja', N'Dễ', '#16A34A', '#DCFCE7', 4.5,
            'https://picsum.photos/seed/ninja-star/600/360', 5, N'10-15 phút',
            N'Phi tiêu ninja (shuriken) 4 cánh ghép từ hai tờ giấy. Mẫu kinh điển mà ai cũng từng gấp thời đi học.',
            (SELECT Id FROM Categories WHERE Name = N'Ngôi sao'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Dễ', 1), (@id, N'Giấy', 2), (@id, N'Ngôi sao', 3);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị hai tờ giấy', N'Cần hai tờ giấy vuông bằng nhau, nên chọn hai màu khác nhau cho đẹp.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Gấp đôi mỗi tờ',       N'Gấp đôi mỗi tờ theo chiều dọc rồi gấp đôi tiếp để được dải giấy hẹp.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Gấp thành chữ Z',      N'Gấp mỗi dải thành hình chữ Z, nhưng gấp ngược chiều nhau giữa hai tờ.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Lồng hai mảnh',        N'Đặt hai mảnh vuông góc rồi luồn các đầu nhọn của mảnh này vào khe của mảnh kia.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Siết chặt hoàn thiện', N'Kéo nhẹ và miết phẳng để hai mảnh khoá vào nhau. Phi tiêu 4 cánh đã sẵn sàng.', 'assets/images/crane_step/step-5.png');
END

-- ─── Tim ─────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Trái tim đơn giản')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Trái tim đơn giản', N'Dễ', '#16A34A', '#DCFCE7', 4.9,
            'https://picsum.photos/seed/simple-heart/600/360', 5, N'5-10 phút',
            N'Trái tim giấy chỉ với vài nếp gấp, hoàn thành trong chưa đầy 10 phút. Rất hợp để kẹp vào thiệp hoặc làm bookmark.',
            (SELECT Id FROM Categories WHERE Name = N'Tim'), 0, 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Dễ', 1), (@id, N'Giấy', 2), (@id, N'Tim', 3), (@id, N'Quà tặng', 4);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông màu đỏ hoặc hồng, mặt màu úp xuống.', 'assets/images/lotus_step/step-1.png'),
    (@id, 2, N'Tạo nếp giữa',        N'Gấp đôi theo chiều dọc rồi mở ra để lấy đường giữa.', 'assets/images/lotus_step/step-2.png'),
    (@id, 3, N'Gấp đỉnh xuống tâm',  N'Gấp góc trên xuống chạm tâm tờ giấy, rồi gấp góc dưới lên chạm mép trên.', 'assets/images/lotus_step/step-3.png'),
    (@id, 4, N'Gấp hai cạnh lên',    N'Gấp hai cạnh dưới lên theo đường giữa để tạo phần thân nhọn của trái tim.', 'assets/images/lotus_step/step-4.png'),
    (@id, 5, N'Bo tròn hoàn thiện',  N'Lật mặt sau, gấp nhẹ 4 góc nhọn phía trên vào trong để bo tròn hai thuỳ trái tim.', 'assets/images/lotus_step/step-5.png');
END

IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Trái tim có cánh')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Trái tim có cánh', N'Trung bình', '#D97706', '#FEF3C7', 4.6,
            'https://picsum.photos/seed/winged-heart/600/360', 5, N'15-20 phút',
            N'Trái tim với đôi cánh nhỏ hai bên, mang ý nghĩa tình yêu tự do. Khó hơn trái tim thường một chút ở bước tạo cánh.',
            (SELECT Id FROM Categories WHERE Name = N'Tim'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Trung bình', 1), (@id, N'Giấy', 2), (@id, N'Tim', 3);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông 15cm, mặt màu úp xuống.', 'assets/images/lotus_step/step-1.png'),
    (@id, 2, N'Gấp nếp cơ bản',      N'Gấp đôi theo chiều ngang và dọc, mở ra để có nếp chữ thập.', 'assets/images/lotus_step/step-2.png'),
    (@id, 3, N'Tạo hình trái tim',   N'Gấp góc trên xuống tâm, gấp hai cạnh dưới vào giữa để tạo dáng trái tim cơ bản.', 'assets/images/lotus_step/step-3.png'),
    (@id, 4, N'Kéo cánh ra',         N'Nhẹ nhàng kéo hai lớp giấy thừa ở hai bên ra ngoài để tạo thành đôi cánh.', 'assets/images/lotus_step/step-4.png'),
    (@id, 5, N'Tạo nếp cánh',        N'Gấp zigzag nhỏ trên mỗi cánh để tạo vân lông vũ, sau đó bo tròn đỉnh trái tim.', 'assets/images/lotus_step/step-5.png');
END

-- ─── Rồng ────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Rồng con')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Rồng con', N'Khó', '#EA580C', '#FFF7ED', 4.7,
            'https://picsum.photos/seed/baby-dragon/600/360', 5, N'30-40 phút',
            N'Phiên bản rút gọn của rồng thần thoại, giữ lại dáng đầu và cánh đặc trưng nhưng ít bước hơn nhiều.',
            (SELECT Id FROM Categories WHERE Name = N'Rồng'), 0, 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Khó', 1), (@id, N'Giấy', 2), (@id, N'Rồng', 3), (@id, N'Thần thoại', 4);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông 20cm để có chỗ gấp các chi tiết nhỏ.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Gấp đế chim',         N'Gấp đế chim (bird base) quen thuộc: gấp chéo, gấp ngang dọc rồi thu gọn thành đế vuông.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Kéo dài thân',        N'Gấp hai cạnh của lớp trên vào giữa ở cả hai mặt để thân rồng dài và hẹp hơn.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Gấp ngược tạo cổ',    N'Gấp ngược một phần nhọn lên trên tạo cổ, gấp ngược tiếp ở đầu mút để tạo đầu rồng.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Tạo cánh và đuôi',    N'Kéo hai lớp bên ra làm cánh, gấp zigzag phần còn lại tạo đuôi có gai. Uốn cong cổ cho có hồn.', 'assets/images/crane_step/step-5.png');
END

IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Đầu rồng')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Đầu rồng', N'Trung bình', '#D97706', '#FEF3C7', 4.3,
            'https://picsum.photos/seed/dragon-head/600/360', 5, N'20-25 phút',
            N'Chỉ gấp phần đầu rồng với sừng và hàm răng, dùng làm mặt nạ ngón tay hoặc đồ trang trí.',
            (SELECT Id FROM Categories WHERE Name = N'Rồng'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Trung bình', 1), (@id, N'Giấy', 2), (@id, N'Rồng', 3);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông màu xanh lá hoặc đỏ, mặt màu úp xuống.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Gấp chéo tạo tam giác', N'Gấp đôi theo đường chéo tạo tam giác, miết phẳng.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Gấp hai góc vào giữa', N'Gấp hai góc đáy vào đường giữa để tạo phần mõm rồng thon dài.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Gấp ngược tạo hàm',   N'Gấp zigzag phần mõm để tạo hàm trên và hàm dưới mở ra.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Tạo sừng và mắt',     N'Gấp hai góc nhỏ phía sau lên tạo sừng, dán hoặc vẽ mắt để hoàn thiện.', 'assets/images/crane_step/step-5.png');
END

-- ─── Thuyền ──────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Thuyền giấy cổ điển')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Thuyền giấy cổ điển', N'Dễ', '#16A34A', '#DCFCE7', 4.6,
            'https://picsum.photos/seed/classic-boat/600/360', 5, N'5-10 phút',
            N'Chiếc thuyền giấy tuổi thơ mà ai cũng biết, thả trôi trên mặt nước sau cơn mưa. Gấp xong trong 5 phút.',
            (SELECT Id FROM Categories WHERE Name = N'Thuyền'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Dễ', 1), (@id, N'Giấy', 2), (@id, N'Thuyền', 3), (@id, N'Truyền thống', 4);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy A4',    N'Dùng tờ giấy A4 đặt nằm dọc. Giấy báo cũng gấp được và nổi tốt trên nước.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Gấp đôi hai lần',     N'Gấp đôi tờ giấy từ trên xuống, rồi gấp đôi theo chiều ngang và mở ra để lấy nếp giữa.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Gấp hai góc vào giữa', N'Gấp hai góc trên vào đường giữa tạo hình tam giác, chừa lại dải giấy phía dưới.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Gấp vành thuyền',     N'Gấp hai dải giấy dưới lên ở cả hai mặt, gài góc thừa vào nhau tạo vành mũ.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Mở thành thuyền',     N'Mở đáy hình mũ ra và ép lại thành hình vuông, rồi kéo hai đỉnh sang hai bên. Thuyền hiện ra.', 'assets/images/crane_step/step-5.png');
END

IF NOT EXISTS (SELECT 1 FROM Tutorials WHERE Title = N'Thuyền buồm')
BEGIN
    INSERT INTO Tutorials (Title, Difficulty, DifficultyColor, DifficultyBg, Rating, ImageUrl, StepCount, Duration, Description, CategoryId, IsFeatured, IsNew)
    VALUES (N'Thuyền buồm', N'Dễ', '#16A34A', '#DCFCE7', 4.4,
            'https://picsum.photos/seed/sailboat-origami/600/360', 5, N'10-15 phút',
            N'Thuyền buồm có cánh buồm tam giác dựng đứng, đặt bàn làm vật trang trí rất xinh.',
            (SELECT Id FROM Categories WHERE Name = N'Thuyền'), 0, 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO TutorialTags VALUES (@id, N'Dễ', 1), (@id, N'Giấy', 2), (@id, N'Thuyền', 3);
    INSERT INTO TutorialSteps (TutorialId, StepOrder, Title, Description, ImageAsset) VALUES
    (@id, 1, N'Chuẩn bị giấy vuông', N'Dùng giấy vuông hai mặt khác màu để thân và buồm phân biệt rõ.', 'assets/images/crane_step/step-1.png'),
    (@id, 2, N'Gấp chéo tạo tam giác', N'Gấp đôi theo đường chéo tạo tam giác, miết phẳng nếp gấp.', 'assets/images/crane_step/step-2.png'),
    (@id, 3, N'Gấp đỉnh xuống',      N'Gấp đỉnh tam giác xuống một đoạn ngắn, phần này sẽ thành thân thuyền.', 'assets/images/crane_step/step-3.png'),
    (@id, 4, N'Dựng cánh buồm',      N'Gấp ngược phần vừa gấp lên trên để hai cánh buồm tam giác dựng đứng.', 'assets/images/crane_step/step-4.png'),
    (@id, 5, N'Gấp đáy cho đứng',    N'Gấp mép đáy vào trong một chút để thuyền đứng vững trên mặt bàn.', 'assets/images/crane_step/step-5.png');
END
GO

PRINT 'Database setup complete!';
GO
