export interface CategoryDocument {
  id?: string;
  uid?: string; // for admin uid check.
  createdAt?: number;
  updatedAt?: number;
  order?: number;
  title?: string;
  description?: string;
  categoryGroup?: string;
  point?: number;
}
