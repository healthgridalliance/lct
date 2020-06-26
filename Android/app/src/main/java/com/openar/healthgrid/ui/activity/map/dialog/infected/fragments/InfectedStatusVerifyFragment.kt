package com.openar.healthgrid.ui.activity.map.dialog.infected.fragments

import android.content.Context
import android.content.DialogInterface
import android.graphics.Rect
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.*
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.transition.TransitionManager
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.openar.healthgrid.R
import com.openar.healthgrid.ui.activity.map.dialog.ShareLocationDialog
import com.openar.healthgrid.ui.activity.map.viewmodel.InfectedStatusViewModel
import com.openar.healthgrid.util.OfflineNotificationUtils
import kotlinx.android.synthetic.main.bottom_sheet_toolbar.*
import kotlinx.android.synthetic.main.confirm_status_info_box.*
import kotlinx.android.synthetic.main.modal_bottom_sheet_confirm_status_fragment.*
import kotlinx.android.synthetic.main.no_connection_alert.*


class InfectedStatusVerifyFragment : BottomSheetDialogFragment() {
    private var actionListener: InfectedStatusVerifyAction? = null
    private val infectedStatusViewModel: InfectedStatusViewModel by viewModels()
    private var lastVisibleDecorViewHeight: Int = 0
    private var density = 1f

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        density = requireActivity().resources.displayMetrics.density
        infectedStatusViewModel.getIdLength().observe(this, Observer { length ->
            if(action_button != null) {
                if (length == InfectedStatusViewModel.MAX_ID_LENGTH) {
                    action_button.isEnabled = true
                    action_button.background = ContextCompat.getDrawable(
                        requireContext(),
                        R.drawable.base_button_box_radius
                    )
                } else {
                    action_button.isEnabled = false
                    action_button.background = ContextCompat.getDrawable(
                        requireContext(),
                        R.drawable.inactive_base_button_box_radius
                    )
                }
            }
        })
        setListenerToRootView()
        return inflater.inflate(R.layout.modal_bottom_sheet_confirm_status_fragment, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        tooltip.visibility = View.GONE
        test_identifier_container.visibility = View.VISIBLE
        header_title.text = getString(R.string.confirm_status_verify_header)
        message.text = getString(R.string.confirm_status_verify_message)
        action_button.isEnabled = false
        action_button.background = ContextCompat.getDrawable(requireContext(), R.drawable.inactive_base_button_box_radius)
        action_button.text = getString(R.string.confirm_status_verify_button_text)
        exit.setOnClickListener {
            hideKeyBoard(sixth)
            actionListener?.onExitButtonTapped() }
        action_button.setOnClickListener {
            if(OfflineNotificationUtils.verifyAvailableNetwork(requireContext())) {
                val dialog = ShareLocationDialog.newInstance(infectedStatusViewModel.testId)
                dialog.show(parentFragmentManager, ShareLocationDialog.DIALOG_TAG)
            } else
                OfflineNotificationUtils.showSnackBarMessage(requireParentFragment().top_coordinator, requireContext())
        }
        leading.setOnClickListener{ actionListener?.openPrevScreen() }
        setUpEditTextListeners(null, first, second)
        setUpEditTextListeners(first, second, third)
        setUpEditTextListeners(second, third, fourth)
        setUpEditTextListeners(third, fourth, fifth)
        setUpEditTextListeners(fourth, fifth, sixth)
        setUpEditTextListeners(fifth, sixth, null)
    }

    private fun setUpEditTextListeners(prev: EditText?, cur: EditText, next: EditText?) {
        cur.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {}
            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {}

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                saveTestId()
                if(before == 0 && count == 1) {
                    if (next != null) next.requestFocus() else hideKeyBoard(cur)
                    infectedStatusViewModel.getIdLength().value?.let {
                        infectedStatusViewModel.setIdLength(it + 1)
                    }
                }
            }
        })

        cur.setOnKeyListener { _, keyCode, event ->
            if (event.action == KeyEvent.ACTION_DOWN && keyCode == KeyEvent.KEYCODE_DEL) {
                if(cur.text.isEmpty()) {
                    if (prev != null) prev.requestFocus() else hideKeyBoard(cur)
                    true
                } else {
                    infectedStatusViewModel.getIdLength().value?.let {
                        infectedStatusViewModel.setIdLength(it - 1)
                    }
                    false
                }
            } else false
        }
    }

    fun hideKeyBoard(v: View) {
        v.requestFocus()
        v.clearFocus()
        if (view != null) {
            val imm: InputMethodManager? = requireContext().getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager?
            imm?.hideSoftInputFromWindow(v.windowToken, 0)
        }
    }

    private fun saveTestId() {
        infectedStatusViewModel.testId =
            first.text.toString() + second.text.toString() + third.text.toString() + fourth.text.toString() + fifth.text.toString() + sixth.text.toString()
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        actionListener = parentFragment as InfectedStatusVerifyAction
    }

    override fun onDetach() {
        actionListener = null
        super.onDetach()
    }

    private fun setListenerToRootView() {
        val activityRootView: View = requireActivity().window.decorView.findViewById(android.R.id.content)
        activityRootView.viewTreeObserver.addOnGlobalLayoutListener {

            val windowVisibleDisplayFrame = Rect()
            activityRootView.getWindowVisibleDisplayFrame(windowVisibleDisplayFrame)
                val visibleDecorViewHeight: Int = windowVisibleDisplayFrame.height()
                if (lastVisibleDecorViewHeight != 0) {
                    if (lastVisibleDecorViewHeight > visibleDecorViewHeight + (MIN_KEYBOARD_HEIGHT_PX * density)) {
                        changeViewGravity(false)
                    } else if (lastVisibleDecorViewHeight + (MIN_KEYBOARD_HEIGHT_PX * density) < visibleDecorViewHeight) {
                        changeViewGravity(true)
                    }
                } else {
                    changeViewGravity(false)
                }
                lastVisibleDecorViewHeight = visibleDecorViewHeight
            }
    }

    private fun changeViewGravity(toCenter: Boolean) {
        if(test_identifier_container != null) {
            TransitionManager.beginDelayedTransition(test_identifier_container.parent as ViewGroup)
            val layoutParams =
                test_identifier_container.layoutParams as FrameLayout.LayoutParams
            if(toCenter)
                layoutParams.gravity = Gravity.CENTER
            else
                layoutParams.gravity = Gravity.TOP
            test_identifier_container.layoutParams = layoutParams
        }
    }

    interface InfectedStatusVerifyAction {
        fun openResultScreen()
        fun onExitButtonTapped()
        fun openPrevScreen()
    }

    companion object {
        const val INFECTED_STATUS_VERIFY = "INFECTED_STATUS_VERIFY"
        const val MIN_KEYBOARD_HEIGHT_PX = 100
        fun newInstance(): InfectedStatusVerifyFragment = InfectedStatusVerifyFragment()
    }
}