<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<c:set var="isEdit" value="${not empty tree}" />
<c:set var="title" value="${isEdit ? 'Edit Tree' : 'Add Tree'}" />

<ui:layout title="${title}" active="trees">
    <ui:header title="${title}" description="${isEdit ? 'Update details for tree ' += tree.code : 'Record a new planting in the orchard.'}">
        <a href="${pageContext.request.contextPath}/trees${isEdit ? '/' += tree.id : ''}"
           class="inline-flex items-center text-sm font-medium text-zinc-600 hover:text-zinc-900 dark:text-zinc-300 dark:hover:text-white">
            ← Back
        </a>
    </ui:header>

    <div class="max-w-2xl rounded-xl border border-zinc-200 bg-white p-6 shadow-xs dark:border-zinc-700 dark:bg-zinc-900">
        <form method="POST" action="${pageContext.request.contextPath}/trees${isEdit ? '/' += tree.id : ''}" enctype="multipart/form-data" class="space-y-6">
            <c:if test="${isEdit}">
                <input type="hidden" name="_method" value="PUT" />
            </c:if>

            <!-- Code & Status -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="code">
                        Tree Code <span class="text-xs text-zinc-400 font-normal">(leave blank to auto-generate)</span>
                    </label>
                    <input id="code" name="code" type="text" value="${h:e(tree.code)}" placeholder="e.g. T-0042"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="status">
                        Status <span class="text-red-500">*</span>
                    </label>
                    <select id="status" name="status" required
                            class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                        <c:forEach var="entry" items="${treeStatuses}">
                            <option value="${entry.key}" ${tree.status == entry.key ? 'selected' : ''}>${entry.value}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- Type & Block -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="tree_type_id">
                        Tree Type <span class="text-red-500">*</span>
                    </label>
                    <select id="tree_type_id" name="tree_type_id" required
                            class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                        <option value="">Select a tree type</option>
                        <c:forEach var="tt" items="${treeTypes}">
                            <option value="${tt.id}" ${tree.tree_type_id == tt.id ? 'selected' : ''}>${h:e(tt.name)}</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="block_id">
                        Block <span class="text-red-500">*</span>
                    </label>
                    <select id="block_id" name="block_id" required
                            class="w-full block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">
                        <option value="">Select a block</option>
                        <c:forEach var="b" items="${blocks}">
                            <option value="${b.id}" ${tree.block_id == b.id ? 'selected' : ''}>${h:e(b.name)}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- Planted Date & Height -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="planted_on">
                        Planted on <span class="text-red-500">*</span>
                    </label>
                    <input id="planted_on" name="planted_on" type="date" required value="${tree.planted_on}"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>

                <div>
                    <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="height_cm">
                        Height (cm)
                    </label>
                    <input id="height_cm" name="height_cm" type="number" step="0.1" value="${tree.height_cm}" placeholder="e.g. 150"
                           class="w-full border block appearance-none text-sm rounded-lg py-2 h-10 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10" />
                </div>
            </div>

            <!-- Notes -->
            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="notes">Notes</label>
                <textarea id="notes" name="notes" rows="3" placeholder="Condition, location details, etc."
                          class="w-full border block appearance-none text-sm rounded-lg py-2 px-3 bg-white dark:bg-white/10 text-zinc-700 dark:text-zinc-300 border-zinc-200 dark:border-white/10">${h:e(tree.notes)}</textarea>
            </div>

            <!-- Photo Upload -->
            <div>
                <label class="block text-sm font-medium text-zinc-800 dark:text-white mb-2" for="photo">Tree Photo</label>
                <input id="photo" name="photo" type="file" accept="image/*"
                       class="w-full text-sm text-zinc-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-[var(--color-accent)] file:text-white hover:file:opacity-90" />
            </div>

            <!-- Action Buttons -->
            <div class="flex items-center justify-end gap-3 pt-4 border-t border-zinc-100 dark:border-zinc-800">
                <a href="${pageContext.request.contextPath}/trees${isEdit ? '/' += tree.id : ''}"
                   class="px-4 py-2 text-sm font-medium text-zinc-700 dark:text-zinc-300 hover:text-zinc-900">Cancel</a>
                <button type="submit"
                        class="px-5 py-2.5 rounded-lg bg-[var(--color-accent)] text-white text-sm font-semibold hover:opacity-90 shadow-sm">
                    ${isEdit ? 'Save changes' : 'Add tree'}
                </button>
            </div>
        </form>
    </div>
</ui:layout>
