package auth

import (
	"time"
)

type Company struct {
	CompanyID        uint      `gorm:"primaryKey;column:company_id"`
	NamaPerusahaan   string    `gorm:"column:nama_perusahaan;not null"`
	NPWP             string    `gorm:"column:npwp;unique;not null"`
	KategoriIndustri string    `gorm:"column:kategori_industri"`
	LimitKredit      float64   `gorm:"column:limit_kredit;default:0.00"`
	CreatedAt        time.Time `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt        time.Time `gorm:"column:updated_at;autoUpdateTime"`
}

func (Company) TableName() string {
	return "auth_module.companies"
}

type User struct {
	UserID       uint      `gorm:"primaryKey;column:user_id"`
	CompanyID    uint      `gorm:"column:company_id"`
	NamaLengkap  string    `gorm:"column:nama_lengkap;not null"`
	Email        string    `gorm:"column:email;unique;not null"`
	PasswordHash string    `gorm:"column:password_hash;not null"`
	Peran        string    `gorm:"column:peran"`
	CreatedAt    time.Time `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt    time.Time `gorm:"column:updated_at;autoUpdateTime"`
}

func (User) TableName() string {
	return "auth_module.users"
}
