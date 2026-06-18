import '../main.dart';

const kCraneSteps = [
  TutorialStep(
    title: 'Chuẩn bị giấy vuông',
    description:
        'Bắt đầu với một tờ giấy hình vuông. Đặt giấy với mặt màu hướng xuống dưới trên mặt phẳng.',
    imageAsset: 'assets/images/crane_step/step-1.png',
  ),
  TutorialStep(
    title: 'Gấp chéo lần 1',
    description:
        'Gấp tờ giấy theo đường chéo từ góc dưới bên trái lên góc trên bên phải. Miết phẳng đường gấp rồi mở ra.',
    imageAsset: 'assets/images/crane_step/step-2.png',
  ),
  TutorialStep(
    title: 'Gấp chéo lần 2',
    description:
        'Gấp theo đường chéo còn lại từ góc dưới bên phải lên góc trên bên trái. Miết phẳng và mở ra.',
    imageAsset: 'assets/images/crane_step/step-3.png',
  ),
  TutorialStep(
    title: 'Gấp đôi theo chiều ngang',
    description:
        'Lật mặt giấy lại. Gấp tờ giấy làm đôi từ trái sang phải tạo hình chữ nhật. Miết phẳng rồi mở ra.',
    imageAsset: 'assets/images/crane_step/step-4.png',
  ),
  TutorialStep(
    title: 'Gấp đôi theo chiều dọc',
    description:
        'Gấp tờ giấy làm đôi từ trên xuống dưới. Miết phẳng rồi mở ra. Lúc này có đủ 4 đường nếp gấp cơ bản.',
    imageAsset: 'assets/images/crane_step/step-5.png',
  ),
  TutorialStep(
    title: 'Thu gọn thành đế sơ bộ',
    description:
        'Sử dụng các nếp gấp có sẵn, đẩy hai cạnh bên vào trong đồng thời để thu gọn tờ giấy thành hình vuông nhỏ hơn với 4 lớp.',
    imageAsset: 'assets/images/crane_step/step-6.png',
  ),
  TutorialStep(
    title: 'Gấp cạnh trái vào giữa',
    description:
        'Xoay hình sao cho phần mở hướng xuống dưới. Gấp cạnh bên trái của lớp trên vào đường thẳng giữa.',
    imageAsset: 'assets/images/crane_step/step-7.png',
  ),
  TutorialStep(
    title: 'Gấp cạnh phải vào giữa',
    description:
        'Gấp cạnh bên phải của lớp trên vào đường thẳng giữa. Hình có dạng con diều.',
    imageAsset: 'assets/images/crane_step/step-8.png',
  ),
  TutorialStep(
    title: 'Gấp góc trên xuống',
    description:
        'Gấp góc trên (tam giác nhỏ) xuống dưới, vượt qua đường ngang nơi hai cạnh vừa gấp gặp nhau.',
    imageAsset: 'assets/images/crane_step/step-9.png',
  ),
  TutorialStep(
    title: 'Mở ra để lộ nếp gấp',
    description:
        'Mở tất cả các nếp gấp vừa thực hiện để trở về hình vuông ban đầu, nhưng giữ lại tất cả các đường nếp.',
    imageAsset: 'assets/images/crane_step/step-10.png',
  ),
  TutorialStep(
    title: 'Gấp cánh trước – petal fold',
    description:
        'Nâng góc dưới của lớp trên lên trên, dùng các nếp có sẵn để ép hai cạnh bên vào trong tạo hình thoi (petal fold).',
    imageAsset: 'assets/images/crane_step/step-11.png',
  ),
  TutorialStep(
    title: 'Hoàn thiện cánh trước',
    description:
        'Miết phẳng cẩn thận để hình thoi phẳng hoàn toàn. Đường trung tâm phải thẳng.',
    imageAsset: 'assets/images/crane_step/step-12.png',
  ),
  TutorialStep(
    title: 'Lật hình',
    description:
        'Lật toàn bộ hình qua mặt sau, giữ cẩn thận để không làm bung các nếp gấp.',
    imageAsset: 'assets/images/crane_step/step-13.png',
  ),
  TutorialStep(
    title: 'Gấp cạnh vào giữa – mặt sau',
    description:
        'Lặp lại bước 7-8 trên mặt này: gấp cạnh trái và phải của lớp trên vào đường giữa.',
    imageAsset: 'assets/images/crane_step/step-14.png',
  ),
  TutorialStep(
    title: 'Gấp cánh sau – petal fold',
    description:
        'Lặp lại petal fold cho mặt sau: nâng góc dưới lên, ép hai bên vào trong tạo hình thoi.',
    imageAsset: 'assets/images/crane_step/step-15.png',
  ),
  TutorialStep(
    title: 'Gấp vạt trái lên – mặt trước',
    description:
        'Trên mặt trước, gấp vạt phía dưới bên trái lên trên theo đường giữa, tạo hình dài và hẹp hơn.',
    imageAsset: 'assets/images/crane_step/step-16.png',
  ),
  TutorialStep(
    title: 'Gấp vạt phải lên – mặt trước',
    description:
        'Gấp vạt phía dưới bên phải lên trên tương tự. Hình giờ trông như chiếc lá dài.',
    imageAsset: 'assets/images/crane_step/step-17.png',
  ),
  TutorialStep(
    title: 'Lật hình',
    description:
        'Lật hình qua mặt sau một lần nữa để xử lý phần còn lại.',
    imageAsset: 'assets/images/crane_step/step-18.png',
  ),
  TutorialStep(
    title: 'Gấp vạt lên – mặt sau',
    description:
        'Lặp lại bước 16-17 trên mặt sau: gấp hai vạt dưới lên theo đường giữa.',
    imageAsset: 'assets/images/crane_step/step-19.png',
  ),
  TutorialStep(
    title: 'Phân chia cánh và đuôi',
    description:
        'Tách hai phần dài ở phía dưới ra, một bên sẽ là đầu và cổ, bên còn lại là đuôi.',
    imageAsset: 'assets/images/crane_step/step-20.png',
  ),
  TutorialStep(
    title: 'Gấp ngược tạo cổ hạc',
    description:
        'Thực hiện gấp ngược (reverse fold) cho một trong hai phần dài: ấn vào trong dọc theo đường giữa để tạo cổ hạc vươn lên.',
    imageAsset: 'assets/images/crane_step/step-21.png',
  ),
  TutorialStep(
    title: 'Gấp ngược tạo đuôi hạc',
    description:
        'Thực hiện gấp ngược tương tự cho phần còn lại để tạo đuôi hạc chỉ lên trên.',
    imageAsset: 'assets/images/crane_step/step-22.png',
  ),
  TutorialStep(
    title: 'Tạo đầu hạc',
    description:
        'Ở phần cổ, thực hiện gấp ngược nhỏ (inside reverse fold) ở đầu mút để tạo mỏ hạc cúi xuống.',
    imageAsset: 'assets/images/crane_step/step-23.png',
  ),
  TutorialStep(
    title: 'Kéo cánh ra',
    description:
        'Nhẹ nhàng kéo hai cánh hạc sang hai bên. Giữ phần thân bằng tay còn lại và kéo đều cả hai phía.',
    imageAsset: 'assets/images/crane_step/step-24.png',
  ),
  TutorialStep(
    title: 'Phồng thân hạc',
    description:
        'Nhẹ nhàng thổi vào lỗ nhỏ ở phần đuôi dưới hoặc ấn nhẹ hai bên hông để thân hạc phồng tròn ra.',
    imageAsset: 'assets/images/crane_step/step-25.png',
  ),
  TutorialStep(
    title: 'Điều chỉnh cánh',
    description:
        'Tiếp tục kéo và điều chỉnh hai cánh để đạt kích thước và góc mong muốn. Cánh nên nằm ngang.',
    imageAsset: 'assets/images/crane_step/step-26.png',
  ),
  TutorialStep(
    title: 'Uốn cổ và cánh',
    description:
        'Uốn cong nhẹ cổ hạc và đầu mút cánh để tạo dáng tự nhiên, uyển chuyển hơn.',
    imageAsset: 'assets/images/crane_step/step-27.png',
  ),
  TutorialStep(
    title: 'Hoàn thành hạc giấy',
    description:
        'Hạc giấy origami của bạn đã hoàn thành! Nhẹ nhàng tinh chỉnh cổ, đầu và cánh để đạt hình dáng đẹp nhất.',
    imageAsset: 'assets/images/crane_step/step-28.png',
  ),
];
