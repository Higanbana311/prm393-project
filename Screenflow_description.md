### <a name="_tl52tdoqnlfq"></a>1. Màn hình Splash (Splash Screen)
Thành phần:

StatelessWidget: Sử dụng cho giao diện tĩnh.

Scaffold: Làm khung nền cho màn hình.

Center + Image.asset/network: Hiển thị logo ứng dụng ở giữa màn hình.

Animation: Hiệu ứng Fade-in

Hành động: Tự động chuyển sang màn hình Onboarding, k cho phép người dùng quay lại(pushReplacemantName)

2\. Màn hình Giới thiệu (Onboarding Screen)

Thành phần:

Column + Padding: Sắp xếp nội dung theo chiều dọc và tạo khoảng cách lề.

Image: Hình ảnh minh họa về nghệ thuật Origami.

Text: Tiêu đề và mô tả ngắn gọn về ứng dụng.

Hành động: Nút bấm ElevatedButton để chuyển đến màn hình Login.
### <a name="_qshf9etqykml"></a>3. Màn hình Đăng nhập/Đăng ký (Login/Signup/Guest)
Thành phần:

Form + GlobalKey: Để quản lý trạng thái và xác thực dữ liệu của toàn bộ form.

TextFormField (Username/Email):

Thuộc tính decoration để hiển thị nhãn "Username/Email".

Thuộc tính validator để kiểm tra bắt buộc (required) và định dạng email.

TextFormField (Password):

obscureText: true để ẩn mật khẩu.

validator kiểm tra độ dài tối thiểu (ví dụ ≥ 8 ký tự).

Suffix Icon: Sử dụng IconButton với Icons.visibility để nhấn/giữ hiển thị mật khẩu.

Sử dụng FocusNode và textInputAction để tự động chuyển ô nhập liệu khi nhấn nút "Next" trên bàn phím.
### <a name="_yp09j7twih26"></a>4. Màn hình Chính (Home Screen)
Thành phần:

Scaffold: Cung cấp AppBar và BottomNavigationBar.

AppBar: Hiển thị tên ứng dụng và icon thông báo.

BottomNavigationBar: 3 tab: Home, Search, Profile.

ListView/Column: Hiển thị các phần như "Featured Origami" hoặc "New Designs".

Card + ListTile: Mỗi mẫu Origami hiển thị dưới dạng thẻ với ảnh thu nhỏ, tên và độ khó.
### <a name="_1dpskh5wyhyc"></a>5. Màn hình Trang cá nhân (Profile Screen)
Thành phần:

CircleAvatar: Hiển thị ảnh đại diện người dùng.

ListTile: Các mục như "My Origami", "Settings".

Switch: Nút bật/tắt chế độ tối (Dark Mode) hoặc thông báo.
### <a name="_vpulnr4m8dwp"></a>6. Màn hình Danh sách Thể loại (Category List)
Thành phần:

GridView.count: Hiển thị danh sách các loại (Động vật, Hoa, Máy bay...) theo dạng lưới.

Responsive UI: Sử dụng MediaQuery để điều chỉnh số cột tương ứng với thiết bị (điện thoại/máy tính).
### <a name="_fy8o2l553ttx"></a>7. Màn hình Tìm kiếm (Search Screen)
Thành phần:

SafeArea: Đảm bảo thanh tìm kiếm không bị che bởi tai thỏ hay các vùng cong của màn hình.

TextField: Ô nhập liệu tìm kiếm với icon kính lúp phía trước.
### <a name="_cps961h79sb7"></a>8. Màn hình Kết quả Tìm kiếm (Search Result)
Thành phần:

ListView.builder: Hiển thị danh sách kết quả một cách tối ưu.

LayoutBuilder: Kiểm tra kích thước màn hình để hiển thị bố cục phù hợp (dạng danh sách/dạng lưới).
### <a name="_ujatsfmb9vzg"></a>9. Màn hình Chi tiết Origami (Origami Detail)
Thành phần:

Stack: Để hiển thị ảnh lớn ở trên cùng với các nút hành động đè lên ảnh.

Chip: Hiển thị các nhãn (Tag) như "Easy", "Paper", "Animal".

Row: Các icon tương tác như "Favorite" (Icons.favorite), "Rate" (Icons.star\_rate), "Share" (Icons.share).

Text: Phần mô tả chi tiết và lịch sử của mẫu Origami.
### <a name="_3lwtrvx7rj1y"></a>10. Màn hình Hướng dẫn từng bước (Step-by-step Tutorial)
Thành phần:

Image: Hình ảnh minh họa cho bước hiện tại.

Slider: Thanh trượt để người dùng theo dõi tiến trình thực hiện (ví dụ: đang ở bước 5/20).

Row: Nút "Previous" và "Next" để di chuyển giữa các bước.
### <a name="_q255qowld49x"></a>11. Màn hình Hoàn thành (Completion Screen)
Thành phần:

Icon(Icons.check\_circle): Biểu tượng thành công lớn ở giữa màn hình.

Text: Lời chúc mừng "Tuyệt vời! Bạn đã hoàn thành mẫu Origami này".

Hành động: Nút "Back to Home" sử dụng Navigator.popUntil hoặc đẩy về màn hình chính.


