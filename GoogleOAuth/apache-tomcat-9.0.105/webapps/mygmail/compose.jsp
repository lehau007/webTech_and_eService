<%@ page session="true" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Soạn thư mới | Compose</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      background-color: #f5f5f5;
    }
    .container {
      max-width: 900px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      background-color: #4285f4;
      color: white;
      padding: 15px;
      border-radius: 5px 5px 0 0;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .header h1 {
      margin: 0;
      font-size: 24px;
    }
    .language-selector {
      margin-left: auto;
    }
    .compose-form {
      background-color: white;
      padding: 20px;
      border-radius: 0 0 5px 5px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12);
    }
    .form-group {
      margin-bottom: 15px;
    }
    label {
      display: block;
      margin-bottom: 5px;
      font-weight: bold;
    }
    input[type="text"], input[type="email"], textarea {
      width: 100%;
      padding: 8px;
      border: 1px solid #dadce0;
      border-radius: 4px;
      box-sizing: border-box;
      font-family: inherit;
      font-size: 14px;
    }
    textarea {
      min-height: 200px;
      resize: vertical;
    }
    .btn {
      padding: 10px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: bold;
      transition: background-color 0.3s;
    }
    .btn-primary {
      background-color: #4285f4;
      color: white;
    }
    .btn-primary:hover {
      background-color: #3367d6;
    }
    .btn-secondary {
      background-color: #f8f9fa;
      color: #3c4043;
      border: 1px solid #dadce0;
      margin-right: 10px;
    }
    .btn-secondary:hover {
      background-color: #f1f3f4;
    }
    .buttons {
      margin-top: 20px;
    }
    .file-input {
      display: none;
    }
    .file-label {
      display: inline-block;
      padding: 8px 16px;
      background-color: #f8f9fa;
      color: #3c4043;
      border: 1px solid #dadce0;
      border-radius: 4px;
      cursor: pointer;
      margin-right: 10px;
    }
    .file-label:hover {
      background-color: #f1f3f4;
    }
    .file-info {
      display: inline-block;
      margin-left: 10px;
      font-size: 14px;
      color: #5f6368;
    }
    .notification {
      padding: 10px;
      margin: 10px 0;
      border-radius: 4px;
      text-align: center;
      display: none;
    }
    .success {
      background-color: #e6f4ea;
      color: #137333;
      border: 1px solid #ceead6;
    }
    .error {
      background-color: #fdecea;
      color: #c5221f;
      border: 1px solid #f5c2c0;
    }
  </style>
  <script>
    // Language strings
    const translations = {
      'en': {
        'compose': 'Compose New Email',
        'to': 'To',
        'subject': 'Subject',
        'body': 'Message',
        'attach': 'Attach File',
        'noFileSelected': 'No file selected',
        'send': 'Send',
        'cancel': 'Cancel',
        'sending': 'Sending...',
        'successMsg': 'Email sent successfully!',
        'errorMsg': 'Error sending email.',
        'requiredFields': 'Please fill in all required fields.',
        'backToInbox': 'Back to Inbox'
      },
      'vi': {
        'compose': 'Soạn thư mới',
        'to': 'Người nhận',
        'subject': 'Tiêu đề',
        'body': 'Nội dung',
        'attach': 'Đính kèm tệp',
        'noFileSelected': 'Chưa chọn tệp nào',
        'send': 'Gửi',
        'cancel': 'Hủy',
        'sending': 'Đang gửi...',
        'successMsg': 'Email đã được gửi thành công!',
        'errorMsg': 'Lỗi khi gửi email.',
        'requiredFields': 'Vui lòng điền đầy đủ các trường bắt buộc.',
        'backToInbox': 'Quay lại Hộp thư đến'
      }
    };

    let currentLanguage = 'vi'; // Default language

    function translate(key) {
      return translations[currentLanguage][key] || translations['en'][key] || key;
    }

    function changeLanguage(lang) {
      currentLanguage = lang;
      updateUI();
    }

    function updateUI() {
      // Update all translated elements
      document.title = translate('compose');
      document.querySelector('.header h1').textContent = translate('compose');
      document.querySelector('label[for="to"]').textContent = translate('to');
      document.querySelector('label[for="subject"]').textContent = translate('subject');
      document.querySelector('label[for="body"]').textContent = translate('body');
      document.querySelector('.file-label').textContent = translate('attach');
      document.querySelector('#send-btn').textContent = translate('send');
      document.querySelector('#cancel-btn').textContent = translate('cancel');
      document.querySelector('#back-to-inbox').textContent = translate('backToInbox');

      // Update file info if needed
      const fileInput = document.getElementById('file');
      const fileInfo = document.getElementById('file-info');
      if (fileInput.files.length > 0) {
        fileInfo.textContent = fileInput.files[0].name;
      } else {
        fileInfo.textContent = translate('noFileSelected');
      }
    }

    async function sendEmail(event) {
      event.preventDefault();

      const toField = document.getElementById('to');
      const subjectField = document.getElementById('subject');
      const bodyField = document.getElementById('body');
      const notification = document.getElementById('notification');

      // Validate required fields
      if (!toField.value || !subjectField.value || !bodyField.value) {
        notification.textContent = translate('requiredFields');
        notification.className = 'notification error';
        notification.style.display = 'block';
        return;
      }

      // Form data for the API call
      const formData = new FormData(document.getElementById('compose-form'));

      // Update the button text and disable it
      const sendBtn = document.getElementById('send-btn');
      const originalText = sendBtn.textContent;
      sendBtn.textContent = translate('sending');
      sendBtn.disabled = true;

      try {
        const response = await fetch('api/send', {
          method: 'POST',
          body: formData
        });

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.error || 'Server error');
        }

        // Show success notification
        notification.textContent = translate('successMsg');
        notification.className = 'notification success';
        notification.style.display = 'block';

        // Reset form
        document.getElementById('compose-form').reset();
        document.getElementById('file-info').textContent = translate('noFileSelected');

        // Redirect to inbox after short delay
        setTimeout(() => {
          window.location.href = 'inbox.jsp';
        }, 2000);

      } catch (error) {
        console.error('Error sending email:', error);
        notification.textContent = `${translations[currentLanguage]['errorMsg'] || translations['en']['errorMsg'] || 'Error sending email.'} ${error.message}`;
        notification.className = 'notification error';
        notification.style.display = 'block';
      } finally {
        // Re-enable the button
        sendBtn.textContent = originalText;
        sendBtn.disabled = false;
      }
    }

    function updateFileInfo() {
      const fileInput = document.getElementById('file');
      const fileInfo = document.getElementById('file-info');

      if (fileInput.files.length > 0) {
        fileInfo.textContent = fileInput.files[0].name;
      } else {
        fileInfo.textContent = translate('noFileSelected');
      }
    }

    window.onload = function() {
      updateUI();

      // Set up language switcher
      document.getElementById('lang-en').addEventListener('click', () => changeLanguage('en'));
      document.getElementById('lang-vi').addEventListener('click', () => changeLanguage('vi'));

      // Set up file input change event
      document.getElementById('file').addEventListener('change', updateFileInfo);

      // Set up form submission
      document.getElementById('compose-form').addEventListener('submit', sendEmail);
    };
  </script>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Soạn thư mới</h1>
      <div class="language-selector">
        <button id="lang-en" class="btn btn-secondary">English</button>
        <button id="lang-vi" class="btn btn-secondary">Tiếng Việt</button>
      </div>
    </div>

    <div id="notification" class="notification"></div>

    <div class="compose-form">
      <form id="compose-form" action="api/send" method="post" enctype="multipart/form-data">
        <div class="form-group">
          <label for="to">Người nhận</label>
          <input type="email" id="to" name="to" required>
        </div>

        <div class="form-group">
          <label for="subject">Tiêu đề</label>
          <input type="text" id="subject" name="subject" required>
        </div>

        <div class="form-group">
          <label for="body">Nội dung</label>
          <textarea id="body" name="body" required></textarea>
        </div>

        <div class="form-group">
          <input type="file" id="file" name="file" class="file-input">
          <label for="file" class="file-label">Đính kèm tệp</label>
          <span id="file-info" class="file-info">Chưa chọn tệp nào</span>
        </div>

        <div class="buttons">
          <button type="submit" id="send-btn" class="btn btn-primary">Gửi</button>
          <button type="button" id="cancel-btn" class="btn btn-secondary" onclick="window.location.href='inbox.jsp'">Hủy</button>
          <a href="inbox.jsp" id="back-to-inbox" class="btn btn-secondary">Quay lại Hộp thư đến</a>
        </div>
      </form>
    </div>
  </div>
</body>
</html>