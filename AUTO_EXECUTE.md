# Auto Execute với Potassium

Mỗi máy cần cài một lần:

1. Tải [potassium_autoexec.luau](https://raw.githubusercontent.com/minztung24-pixel/virus-visualizer-loader/main/potassium_autoexec.luau).
2. Chép file vào thư mục `%LOCALAPPDATA%\Potassium\autoexec\` (tạo thư mục nếu chưa có).
3. Vào **Steal An Egg**. Lần đầu file sẽ tự tải `client.lua`. Trong giao diện THT Item Visualizer, nút **Auto Execute** lưu lựa chọn bật/tắt cho place này.

Với game khác, chạy `load.lua` một lần rồi bật **Auto Execute** trong giao diện. Cài đặt được lưu riêng theo PlaceId. Khi đổi máy, cần chép lại file autoexec; bản thân file cài đặt trong Potassium không tự tạo file đó.

Auto Execute chỉ chạy khi vào game và môi trường Potassium hỗ trợ autoexec, `loadstring` và HTTP. Nếu file cài đặt có `autoExecute=false`, file autoexec sẽ không tải script.
