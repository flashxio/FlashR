/*
 * Copyright 2016 Open Connectome Project (http://openconnecto.me)
 * Written by Da Zheng (zhengda1936@gmail.com)
 *
 * This file is part of FlashMatrix.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "combined_matrix_store.h"

namespace fm
{

namespace detail
{

struct mat_info
{
	size_t nrow;
	size_t ncol;
	bool in_mem;
	const scalar_type &type;
};

static mat_info get_matrix_info(const std::vector<matrix_store::ptr> &mats)
{
	mat_info info;
	bool is_wide = mats.front()->is_wide();
	if (is_wide) {
		const matrix_store &store = *mats.front();
		info.nrow = store.get_num_rows();
		info.ncol = store.get_num_cols();
		info.in_mem = store.is_in_mem();
		info.type = store.get_type();
	}
	for (size_t i = 1; i < mats.size(); i++) {
		if (is_wide)
			info.nrow += store.get_num_rows();
		else
			info.ncol += store.get_num_cols();
		info.in_mem = info.in_mem && store.is_in_mem();
	}
	return info;
}

class combined_tall_matrix_store: public combined_matrix_store
{
public:
	combined_tall_matrix_store(const std::vector<matrix_store::ptr> &mats,
			matrix_layout_t layout): combined_matrix_store(mats, layout,
				get_matrix_info(mats)) {
	}
};

class combined_wide_matrix_store: public combined_matrix_store
{
public:
	combined_wide_matrix_store(const std::vector<matrix_store::ptr> &mats,
			matrix_layout_t layout): combined_matrix_store(mats, layout,
				get_matrix_info(mats)) {
	}
};

combined_matrix_store::ptr combined_matrix_store::create(
		const std::vector<matrix_store::ptr> &mats, matrix_layout_t layout)
{
	if (mats.empty()) {
		BOOST_LOG_TRIVIAL(error) << "can't combine 0 matrices";
		return combined_matrix_store::ptr();
	}
	const scalar_type &type = mats.front()->get_type();
	bool is_wide = mats.front()->is_wide();
	for (size_t i = 1; i < mats.size(); i++) {
		if (mats[i]->get_type != type) {
			BOOST_LOG_TRIVIAL(error)
				<< "can't combine matrices of different element types";
			return combined_matrix_store::ptr();
		}
		if (mats[i]->is_wide() != is_wide) {
			BOOST_LOG_TRIVIAL(error)
				<< "can't combine matrices of different row/col length";
			return combined_matrix_store::ptr();
		}
	}
	if (is_wide) {
		size_t num_cols = mats.front()->get_num_cols();
		for (size_t i = 1; i < mats.size(); i++) {
			if (mats[i]->get_num_cols() != num_cols) {
				BOOST_LOG_TRIVIAL(error)
					<< "can't combine matrices with different row lengths";
				return combined_matrix_store::ptr();
			}
		}
		return ptr(new combined_wide_matrix_store(mats, layout));
	}
	else {
		size_t num_rows = mats.front()->get_num_rows();
		for (size_t i = 1; i < mats.size(); i++) {
			if (mats[i]->get_num_rows() != num_rows) {
				BOOST_LOG_TRIVIAL(error)
					<< "can't combine matrices with different col lengths";
				return combined_matrix_store::ptr();
			}
		}
		return ptr(new combined_tall_matrix_store(mats, layout));
	}
}

combined_matrix_store::combined_matrix_store(
		const std::vector<matrix_store::ptr> &mats, matrix_layout_t layout,
		const mat_info &info): matrix_store(info.nrow, info.ncol, info.in_mem,
			info.type)
{
	num_nodes = -1;
	for (size_t i = 0; i < mats.size(); i++) {
		if (mats[i]->get_num_nodes() > 0 && num_nodes < 0)
			num_nodes = mats[i]->get_num_nodes();
		if (mats[i]->get_num_nodes() > 0 && num_nodes > 0)
			assert(num_nodes == mats[i]->get_num_nodes());
	}
	this->layout = layout;

	// We use the largest portion size among the matrices as the portion size
	// of the combined matrix.
	if (mats.front()->is_wide()) {
		portion_size = mats.front()->get_portion_size();
		for (size_t i = 1; i < mats.size(); i++) {
			auto tmp = mats[i]->get_portion_size();
			portion_size.second = std::max(portion_size.second, tmp.second);
		}
		portion_size.first = get_num_rows();
	}
	else {
		portion_size = mats.front()->get_portion_size();
		for (size_t i = 1; i < mats.size(); i++) {
			auto tmp = mats[i]->get_portion_size();
			portion_size.first = std::max(portion_size.first, tmp.first);
		}
		portion_size.second = get_num_cols();
	}
}

std::string combined_matrix_store::get_name() const
{
	std::string name = std::string("combine(") + mats[0]->get_name();
	for (size_t i = 1; mats.size(); i++)
		name += std::string(", ") + mats[i]->get_name();
	name += ")";
	return name;
}

bool combined_matrix_store::reset_data()
{
	for (size_t i = 0; i < mats.size(); i++)
		if (mats[i]->read_only())
			return false;
	matrix_store::reset_data();
}

bool combined_matrix_store::set_data(const set_operate &op)
{
	for (size_t i = 0; i < mats.size(); i++)
		if (mats[i]->read_only())
			return false;
	matrix_store::set_data(op);
}

bool combined_matrix_store::is_virtual() const
{
	for (size_t i = 0; i < mats.size(); i++)
		if (mats[i]->is_virtual())
			return true;
	return false;
}

void combined_matrix_store::materialize_self() const
{
	for (size_t i = 0; i < mats.size(); i++)
		mats[i]->materialize_self();
}

void combined_matrix_store::set_cache_portion(bool cache_portion)
{
	for (size_t i = 0; i < mats.size(); i++)
		mats[i]->set_cache_portion(cache_portion);
}

int combined_matrix_store::get_portion_node_id(size_t id) const
{
	if (!is_in_mem())
		return -1;
	for (size_t i = 0; i < mats.size(); i++) {
		// I assume all matrices have the same portion size.
		// If they are NUMA matrices, they share the same mapping.
		int node_id = mats[i]->get_portion_node_id(id);
		if (node_id > 0)
			return node_id;
	}
	return -1;
}

async_cres_t combined_matrix_store::get_portion_async(size_t start_row,
		size_t start_col, size_t num_rows, size_t num_cols,
		portion_compute::ptr compute) const
{
	auto ret = const_cast<combined_matrix_store *>(this)->get_portion_async(
			start_row, start_col, num_rows, num_cols, compute);
	return async_cres_t(ret.first, ret.second);
}

local_matrix_store::const_ptr combined_matrix_store::get_portion(
		size_t start_row, size_t start_col, size_t num_rows,
		size_t num_cols) const
{
	return const_cast<combined_matrix_store *>(this)->get_portion(
			start_row, start_col, num_rows, num_cols);
}

async_res_t combined_matrix_store::get_portion_async(size_t start_row,
		size_t start_col, size_t num_rows, size_t num_cols,
		portion_compute::ptr compute)
{
}

local_matrix_store::ptr combined_matrix_store::get_portion(
		size_t start_row, size_t start_col, size_t num_rows,
		size_t num_cols)
{
	local_matrix_store::ptr buf;
	if (store_layout() == matrix_layout_t::L_ROW)
		buf = local_matrix_store::ptr(new local_buf_row_matrix_store(start_row,
					start_col, num_rows, num_cols, get_type(), -1));
	else
		buf = local_matrix_store::ptr(new local_buf_col_matrix_store(start_row,
					start_col, num_rows, num_cols, get_type(), -1));

	if (is_wide()) {
		assert(start_row == 0 && num_rows == get_num_rows());
		size_t row_idx = start_row;
		for (size_t i = 0; i < mats.size(); i++) {
			local_matrix_store::ptr tmp = mats[i]->get_portion(0,
					start_col, mats[i]->get_num_rows(), num_cols);
			assert(tmp);
			buf->resize(row_idx, start_col, mats[i]->get_num_rows(), num_cols);
			// TODO I need to test the performance of memory copy
			// It might be slow.
			buf->copy_from(*tmp);
			row_idx += mats[i]->get_num_rows();
		}
		assert(row_idx == get_num_rows());
	}
	else {
		assert(start_col == 0 && num_cols == get_num_cols());
		size_t col_idx = start_col;
		for (size_t i = 0; i < mats.size(); i++) {
			local_matrix_store::ptr tmp = mats[i]->get_portion(start_row,
					0, num_rows, mats[i]->get_num_cols());
			assert(tmp);
			buf->resize(start_row, col_idx, num_rows, mats[i]->get_num_cols());
			buf->copy_from(*tmp);
			col_idx += mats[i]->get_num_cols();
		}
		assert(col_idx == get_num_cols());
	}

	// we should return a read-only local matrix store.
	if (store_layout() == matrix_layout_t::L_ROW) {
		local_buf_row_matrix_store::ptr row_buf
			= std::static_pointer_cast<local_buf_row_matrix_store>(buf);
		return local_cref_contig_row_matrix_store::ptr(
				new local_cref_contig_row_matrix_store(row_buf->get_data(),
					buf->get_raw_arr(), buf->get_global_start_row(),
					buf->get_global_start_col(), buf->get_num_rows(),
					buf->get_num_cols(), buf->get_type(), buf->get_node_id()))
	}
	else {
		local_buf_col_matrix_store::ptr col_buf
			= std::static_pointer_cast<local_buf_col_matrix_store>(buf);
		return local_cref_contig_col_matrix_store::ptr(
				new local_cref_contig_col_matrix_store(col_buf->get_data(),
					buf->get_raw_arr(), buf->get_global_start_row(),
					buf->get_global_start_col(), buf->get_num_rows(),
					buf->get_num_cols(), buf->get_type(), buf->get_node_id()));
	}
}

void combined_matrix_store::write_portion_async(
		local_matrix_store::const_ptr portion,
		off_t start_row, off_t start_col)
{
}

matrix_store::const_ptr combined_tall_matrix_store::transpose() const
{
}

matrix_store::const_ptr combined_wide_matrix_store::transpose() const
{
}

}

}
