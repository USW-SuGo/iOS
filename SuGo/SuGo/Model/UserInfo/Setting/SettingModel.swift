//
//  SettingModel.swift
//  SuGo
//
//  Created by 한지석 on 2023/03/05.
//

import Foundation

struct SettingModel {
  // menuCategories, loginMenus
  let menuCategories = ["알림 설정", "계정 관리", "기타"]
  let loginMenus = [
    ["알림 켜기/끄기"],
    ["비밀번호 변경", "이용제한 내역", "로그아웃", "회원탈퇴"],
    ["공지사항", "이용 약관", "개인정보 처리 방침", "피드백 전송 및 문의하기"]
  ]
}
